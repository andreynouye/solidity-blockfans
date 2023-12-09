<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>Create Key</h1>

                <form @submit.prevent="createKey">
                    <div>
                        <input for="keyName" type="text" placeholder="Name" required />
                    </div>
                    <div>
                        <input for="keyDescription" type="text" placeholder="Description" required />
                    </div>
                    <div>
                        <input for="keyImage" type="text" placeholder="Image" required />
                    </div>
                    <div>
                        <input for="keyExternalURL" type="text" placeholder="External URL" required />
                    </div>
                    <div>
                        <input for="keyDuration" type="number" placeholder="Duration" required />
                    </div>
                    <div>
                        <input for="keyPrice" type="number" placeholder="Price" required />
                    </div>
                    <div>
                        <input for="keyUnits" type="number" placeholder="Units" required />
                    </div>

                    <button type="submit" :disabled="buttonCreateWaiting">
                        {{ buttonCreateWaiting ? "Creating Key..." : "Create Key" }}
                    </button>
                </form>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref } from "vue";

export default {
    name: "KeysCreate",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsKeysContract = inject("creatorsKeysContract");

        const buttonCreateWaiting = ref(false);

        const createKey = async () => {
            console.log(creatorsKeysContract);
            const keyName = document.querySelector('input[for="keyName"]').value;
            const keyDescription = document.querySelector('input[for="keyDescription"]').value;
            const keyImage = document.querySelector('input[for="keyImage"]').value;
            const keyExternalURL = document.querySelector('input[for="keyExternalURL"]').value;
            const keyDuration = document.querySelector('input[for="keyDuration"]').value;
            const keyPrice = document.querySelector('input[for="keyPrice"]').value;
            const keyUnits = document.querySelector('input[for="keyUnits"]').value;
            try {
                buttonCreateWaiting.value = true;
                await creatorsKeysContract.value.methods.setKeySource(keyName, keyDescription, keyImage, keyExternalURL, keyDuration, keyPrice, keyUnits).send({ from: account.value });
                await Promise.all([]);
            } catch (error) {
                console.error(error);
            } finally {
                buttonCreateWaiting.value = false;
            }
        };
        return {
            web3,
            account,

            buttonCreateWaiting,

            createKey,
        };
    },
};
</script>
