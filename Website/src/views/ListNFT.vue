<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>List NFTs</h1>
                <ul v-if="nfts.length > 0">
                    <li v-for="nft in nfts" :key="nft.sourceId">
                        NFT: {{ nft }} ID: {{ nft.sourceId }}
                        <button v-if="nft.status == 0 || nft.status == 1" :id="'remove-' + nft.sourceId" @click="remove(nft.sourceId)">Remove</button>
                        <button v-if="nft.status == 3" :id="'restore-' + nft.sourceId" @click="restore(nft.sourceId)">Restore</button>
                        <button v-if="nft.status == 3" :id="'permanentRemove-' + nft.sourceId" @click="permanentRemove(nft.sourceId)">Permanent Remove</button>
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
                const results = await creatorsNFTContract.value.methods.getNFTDetailsByCreator().send({ from: account.value });

                const nftsWithSales = [];
                for (const nft of results) {
                    try {
                        const salesCount = await creatorsNFTContract.value.methods.getSoldUnitsPerSource(nft.sourceId).call();
                        nftsWithSales.push({ ...nft, salesCount });
                    } catch (error) {
                        console.error("Error with NFT:", nft, error);
                    }
                }

                nfts.value = nftsWithSales.sort((a, b) => b.sourceId - a.sourceId);

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

        const permanentRemove = async (sourceId) => {
            try {
                await creatorsNFTContract.value.methods.permanentDeleteNFTSource(sourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const restore = async (sourceId) => {
            try {
                await creatorsNFTContract.value.methods.restoreNFTSource(sourceId).send({ from: account.value });
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
            permanentRemove,
            restore
        };
    },
};
</script>
