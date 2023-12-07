<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>History</h1>
                <ul v-if="nfts.length > 0">
                    <li v-for="nft in nfts" :key="nft.modelId">NFT: {{ nft }}</li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, onMounted } from "vue";

export default {
    name: "PlansHistory",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsPlansContract = inject("creatorsPlansContract");

        const nfts = ref([]);
        const loading = ref(true);

        const getPlans = async () => {
            try {
                loading.value = true;
                nfts.value = [];

                // Obter o número total de NFTs possuídos pelo usuário
                const balance = await creatorsPlansContract.value.methods.balanceOf(account.value).call();

                // Obter os IDs de cada NFT possuído e buscar seus detalhes
                for (let i = 0; i < balance; i++) {
                    const tokenId = await creatorsPlansContract.value.methods.tokenOfOwnerByIndex(account.value, i).call();
                    const nftDetail = await creatorsPlansContract.value.methods.nfts(tokenId).call();
                    nfts.value.push({ tokenId, ...nftDetail });
                }

                console.log("nfts.value: ", nfts.value);
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            loading.value = true;
            await getPlans();
            loading.value = false;
        });

        return {
            web3,
            account,

            nfts,
            loading,

            getPlans,
        };
    },
};
</script>
