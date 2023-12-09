<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>List Keys</h1>
                <ul v-if="keys.length > 0">
                    <li v-for="key in keys" :key="key.keySourceId">
                        Key: {{ key }} ID: {{ key.keySourceId }}
                        <button v-if="key.status == 0 || key.status == 1" :id="'remove-' + key.keySourceId" @click="remove(key.keySourceId)">Remove</button>
                        <button v-if="key.status == 3" :id="'restore-' + key.keySourceId" @click="restore(key.keySourceId)">Restore</button>
                        <button v-if="key.status == 3" :id="'permanentRemove-' + key.keySourceId" @click="permanentRemove(key.keySourceId)">Permanent Remove</button>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, onMounted } from "vue";

export default {
    name: "MyKeys",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsKeysContract = inject("creatorsKeysContract");

        const keys = ref([]);
        const loading = ref(true);

        const created = async () => {
            try {
                loading.value = true;
                const results = await creatorsKeysContract.value.methods.getKeyDetailsByCreator().call({ from: account.value });
                console.log("results:", results);
                const keysWithSales = [];
                for (const key of results) {
                    try {
                        const salesCount = await creatorsKeysContract.value.methods.getSoldUnitsPerSource(key.keySourceId).call();
                        keysWithSales.push({ ...key, salesCount });
                    } catch (error) {
                        console.error("Error with Key:", key, error);
                    }
                }

                keys.value = keysWithSales.sort((a, b) => b.keySourceId - a.keySourceId);
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        const remove = async (keySourceId) => {
            try {
                await creatorsKeysContract.value.methods.deleteKeySource(keySourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const permanentRemove = async (keySourceId) => {
            try {
                await creatorsKeysContract.value.methods.permanentDeleteKeySource(keySourceId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const restore = async (keySourceId) => {
            try {
                await creatorsKeysContract.value.methods.restoreKeySource(keySourceId).send({ from: account.value });
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

            keys,
            loading,

            created,
            remove,
            permanentRemove,
            restore,
        };
    },
};
</script>
