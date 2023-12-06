<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>List Creators</h1>
                <ul v-if="creators.length > 0">
                    <li v-for="creator in creators" :key="creator">
                        <router-link :to="`/u/${creator}`">{{ creator }}</router-link>
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

        const creatorsContract = inject("creatorsContract");

        const creators = ref([]);
        const loading = ref(true);

        const getCreators = async () => {
            try {
                loading.value = true;
                creators.value = await creatorsContract.value.methods.getCreators().call();
                console.log("creators.value:", creators.value);
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            loading.value = true;
            await getCreators();
            loading.value = false;
        });

        return {
            web3,
            account,

            creators,
            loading,

            getCreators,
        };
    },
};
</script>
