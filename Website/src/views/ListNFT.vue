<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>List NFTs</h1>
                <ul v-if="nfts.length > 0">
                    <li v-for="nft in nfts" :key="nft.sourceId">
                        NFT: {{ nft }} ID: {{ nft.sourceId }}
                        <button :id="'remove-' + nft.sourceId" @click="remove(nft.sourceId)">Remove</button>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, onMounted } from "vue";

export default {
    name: "MyNFTs",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsNFTContract = inject("creatorsNFTContract");

        const nfts = ref([]);
        const loading = ref(true);

        const created = async () => {
            try {
                loading.value = true;
                const results = await creatorsNFTContract.value.methods.getNFTDetailsByCreator(account.value).call();

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

        const remove = async (sourceId) => {
            try {
                await creatorsNFTContract.value.methods.deleteNFTSource(sourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
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

            nfts,
            loading,

            created,
            remove,
        };
    },
};
</script>
