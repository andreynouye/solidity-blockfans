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
                <h2>Keys</h2>
                <ul v-if="keys.length > 0">
                    <li v-for="key in keys" :key="key.keySourceId">
                        NFT: {{ key }} ID: {{ key.keySourceId }}
                        <button v-if="key.salesCount < key.units || key.units == 0" :id="'buyKey-' + key.keySourceId" @click="buyKey(key.keySourceId, key.price)">Buy</button>
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

        const LockeekContract = inject("LockeekContract");
        const creatorsNFTContract = inject("creatorsNFTContract");
        const creatorsKeysContract = inject("creatorsKeysContract");

        const nfts = ref([]);
        const keys = ref([]);
        const loading = ref(true);

        console.log("username:", username);

        const approve = async (valueInWei, contractToApprove) => {
            try {
                const allowance = await LockeekContract.value.methods.allowance(account.value, contractToApprove.value._address).call();
                if (Web3.utils.toBN(allowance.toString()).gte(Web3.utils.toBN(valueInWei))) {
                    return true;
                } else {
                    await LockeekContract.value.methods.approve(contractToApprove.value._address, valueInWei).send({ from: account.value });
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

        const buyKey = async (keySourceId, price) => {
            const value = price;
            const valueInWei = Web3.utils.toWei(value.toString(), "ether");
            const isApproved = await approve(valueInWei, creatorsKeysContract);
            if (!isApproved) return;

            try {
                console.log("keySourceId: ", keySourceId);
                await creatorsKeysContract.value.methods.buyKey(keySourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await createdKeys();
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

        const createdKeys = async () => {
            try {
                loading.value = true;
                const results = await creatorsKeysContract.value.methods.getPublicKeyDetailsByCreator(username.value).call();

                console.log("key results:", results);
                const keysWithSales = await Promise.all(
                    results.map(async (key) => {
                        console.log("key:", key);
                        const salesCount = await creatorsKeysContract.value.methods.getSoldUnitsPerSource(key.keySourceId).call();
                        return { ...key, salesCount };
                    })
                );
                console.log("keysWithSales:", keysWithSales);

                keys.value = keysWithSales;
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            loading.value = true;
            await createdNFTs();
            await createdKeys();
            loading.value = false;
        });

        return {
            web3,
            account,
            username,

            nfts,
            keys,
            loading,

            buyNFT,
            buyKey,
            createdNFTs,
            createdKeys,
        };
    },
};
</script>
