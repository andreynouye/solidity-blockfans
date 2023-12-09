<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>Owned Keys</h1>
                <ul v-if="keys.length > 0">
                    <li v-for="key in keys" :key="key.modelId">Key: {{ key }}</li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, onMounted } from "vue";

export default {
    name: "OwnedKeys",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsKeysContract = inject("creatorsKeysContract");

        const keys = ref([]);
        const loading = ref(true);

        const getKeys = async () => {
            try {
                loading.value = true;
                keys.value = [];

                // Obter o número total de Keys possuídos pelo usuário
                const balance = await creatorsKeysContract.value.methods.balanceOf(account.value).call();

                // Obter os IDs de cada Key possuído e buscar seus detalhes
                for (let i = 0; i < balance; i++) {
                    const tokenId = await creatorsKeysContract.value.methods.tokenOfOwnerByIndex(account.value, i).call();
                    const keyDetail = await creatorsKeysContract.value.methods.keys(tokenId).call();
                    keys.value.push({ tokenId, ...keyDetail });
                }

                console.log("keys.value: ", keys.value);
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        onMounted(async () => {
            loading.value = true;
            await getKeys();
            loading.value = false;
        });

        return {
            web3,
            account,

            keys,
            loading,

            getKeys,
        };
    },
};
</script>
