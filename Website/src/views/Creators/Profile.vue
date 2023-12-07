<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>User Details</h1>
                <ul>
                    <li>Address: {{ username }}</li>
                </ul>
                <h2>NFTs</h2>
                <ul v-if="nfts.length > 0">
                    <li v-for="nft in nfts" :key="nft.sourceId">
                        NFT: {{ nft }} ID: {{ nft.sourceId }}
                        <button v-if="nft.salesCount < nft.units || nft.units == 0" :id="'buyNFT-' + nft.sourceId" @click="buyNFT(nft.sourceId, nft.price)">Buy</button>
                    </li>
                </ul>
                <h2>Plans</h2>
                <ul v-if="plans.length > 0">
                    <li v-for="plan in plans" :key="plan.planId">
                        NFT: {{ plan }} ID: {{ plan.planId }}
                        <button v-if="plan.salesCount < plan.units || plan.units == 0" :id="'buyPlan-' + plan.planId" @click="buyPlan(plan.planId, plan.price)">Buy</button>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import Web3 from "web3";
import { inject, ref, onMounted } from "vue";
import { useRoute } from "vue-router";

export default {
    name: "CretorsProfile",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const route = useRoute();
        const username = ref(route.params.username);

        const blockFansContract = inject("blockFansContract");
        const creatorsNFTContract = inject("creatorsNFTContract");
        const creatorsPlansContract = inject("creatorsPlansContract");

        const nfts = ref([]);
        const plans = ref([]);
        const loading = ref(true);

        console.log("username:", username);

        const approve = async (valueInWei, contractToApprove) => {
            try {
                const allowance = await blockFansContract.value.methods.allowance(account.value, contractToApprove.value._address).call();
                if (Web3.utils.toBN(allowance.toString()).gte(Web3.utils.toBN(valueInWei))) {
                    return true;
                } else {
                    await blockFansContract.value.methods.approve(contractToApprove.value._address, valueInWei).send({ from: account.value });
                    return true;
                }
            } catch (err) {
                console.error("Error approving spending:", err);
                return false;
            }
        };

        const buyNFT = async (sourceId, price) => {
            const value = price;
            const valueInWei = Web3.utils.toWei(value.toString(), "ether");
            const isApproved = await approve(valueInWei, creatorsNFTContract);
            if (!isApproved) return;

            try {
                console.log("sourceId: ", sourceId);
                await creatorsNFTContract.value.methods.buyNFT(sourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await createdNFTs();
            }
        };

        const buyPlan = async (planId, price) => {
            const value = price;
            const valueInWei = Web3.utils.toWei(value.toString(), "ether");
            const isApproved = await approve(valueInWei, creatorsPlansContract);
            if (!isApproved) return;

            try {
                console.log("planId: ", planId);
                await creatorsPlansContract.value.methods.buyPlan(planId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await createdPlans();
            }
        };

        const createdNFTs = async () => {
            try {
                loading.value = true;
                const results = await creatorsNFTContract.value.methods.getPublicNFTDetailsByCreator(username.value).call();

                console.log("results:", results);
                const nftsWithSales = await Promise.all(
                    results.map(async (nft) => {
                        console.log("nft:", nft);
                        const salesCount = await creatorsNFTContract.value.methods.getSoldUnitsPerSource(nft.sourceId).call();
                        return { ...nft, salesCount };
                    })
                );
                console.log("nftsWithSales:", nftsWithSales);

                nfts.value = nftsWithSales;
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        const createdPlans = async () => {
            try {
                loading.value = true;
                const results = await creatorsPlansContract.value.methods.getPublicPlanDetailsByCreator(username.value).call();

                console.log("plan results:", results);
                const plansWithSales = await Promise.all(
                    results.map(async (plan) => {
                        console.log("plan:", plan);
                        const salesCount = await creatorsPlansContract.value.methods.getSoldUnitsPerPlan(plan.planId).call();
                        return { ...plan, salesCount };
                    })
                );
                console.log("plansWithSales:", plansWithSales);

                plans.value = plansWithSales;
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            loading.value = true;
            await createdNFTs();
            await createdPlans();
            loading.value = false;
        });

        return {
            web3,
            account,
            username,

            nfts,
            plans,
            loading,

            buyNFT,
            buyPlan,
            createdNFTs,
            createdPlans,
        };
    },
};
</script>
