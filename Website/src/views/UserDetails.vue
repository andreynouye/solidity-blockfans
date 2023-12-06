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
                        <button v-if="nft.salesCount < nft.units" :id="'buy-' + nft.sourceId" @click="buy(nft.sourceId, nft.price)">Buy</button>
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
    name: "UserDetails",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const route = useRoute();
        const username = ref(route.params.username);

        const blockFansContract = inject("blockFansContract");
        const creatorsNFTContract = inject("creatorsNFTContract");

        const nfts = ref([]);
        const loading = ref(true);

        console.log("username:", username);

        const approve = async (valueInWei) => {
            try {
                const allowance = await blockFansContract.value.methods.allowance(account.value, creatorsNFTContract.value._address).call();
                if (Web3.utils.toBN(allowance.toString()).gte(Web3.utils.toBN(valueInWei))) {
                    return true;
                } else {
                    await blockFansContract.value.methods.approve(creatorsNFTContract.value._address, valueInWei).send({ from: account.value });
                    return true;
                }
            } catch (err) {
                console.error("Error approving spending:", err);
                return false;
            }
        };

        const buy = async (sourceId, price) => {
            const value = price;
            const valueInWei = Web3.utils.toWei(value.toString(), "ether");
            const isApproved = await approve(valueInWei);
            if (!isApproved) return;

            try {
                console.log("sourceId: ", sourceId);
                await creatorsNFTContract.value.methods.buyNFT(sourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const created = async () => {
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

        onMounted(async () => {
            loading.value = true;
            await created();
            loading.value = false;
        });

        return {
            web3,
            account,
            username,

            nfts,
            loading,

            buy,
            created,
        };
    },
};
</script>
