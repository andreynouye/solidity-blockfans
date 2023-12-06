<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>Create NFT</h1>

                <form @submit.prevent="createNFT">
                    <div>
                        <input for="nftName" type="text" placeholder="Name" required />
                    </div>
                    <div>
                        <input for="nftDescription" type="text" placeholder="Description" required />
                    </div>
                    <div>
                        <input for="nftImage" type="text" placeholder="Image" required />
                    </div>
                    <div>
                        <input for="nftExternalURL" type="text" placeholder="External URL" required />
                    </div>
                    <div>
                        <input for="nftPrice" type="text" placeholder="Price" required />
                    </div>
                    <div>
                        <input for="nftUnits" type="number" placeholder="Units" required />
                    </div>
                    <div>
                        <input for="nftMediaType" type="text" placeholder="Media Type" required />
                    </div>

                    <button type="submit" :disabled="buttonCreateWaiting">
                        {{ buttonCreateWaiting ? "Creating NFT..." : "Create NFT" }}
                    </button>
                </form>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref } from "vue";

export default {
    name: "CreateNFT",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsNFTContract = inject("creatorsNFTContract");

        const buttonCreateWaiting = ref(false);

        const createNFT = async () => {
            console.log(creatorsNFTContract);
            const nftName = document.querySelector('input[for="nftName"]').value;
            const nftDescription = document.querySelector('input[for="nftDescription"]').value;
            const nftImage = document.querySelector('input[for="nftImage"]').value;
            const nftExternalURL = document.querySelector('input[for="nftExternalURL"]').value;
            const nftPrice = document.querySelector('input[for="nftPrice"]').value;
            const nftUnits = document.querySelector('input[for="nftUnits"]').value;
            const nftMediaType = document.querySelector('input[for="nftMediaType"]').value;
            try {
                buttonCreateWaiting.value = true;
                await creatorsNFTContract.value.methods.setNFTSource(nftName, nftDescription, nftImage, nftExternalURL, nftPrice, nftUnits, nftMediaType).send({ from: account.value });
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

            createNFT,
        };
    },
};
</script>
