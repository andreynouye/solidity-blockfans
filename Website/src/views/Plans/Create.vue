<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>Create Plan</h1>

                <form @submit.prevent="createPlan">
                    <div>
                        <input for="planName" type="text" placeholder="Name" required />
                    </div>
                    <div>
                        <input for="planDescription" type="text" placeholder="Description" required />
                    </div>
                    <div>
                        <input for="planExternalURL" type="text" placeholder="External URL" required />
                    </div>
                    <div>
                        <input for="planDuration" type="number" placeholder="Duration" required />
                    </div>
                    <div>
                        <input for="planPrice" type="number" placeholder="Price" required />
                    </div>
                    <div>
                        <input for="planUnits" type="number" placeholder="Units" required />
                    </div>

                    <button type="submit" :disabled="buttonCreateWaiting">
                        {{ buttonCreateWaiting ? "Creating Plan..." : "Create Plan" }}
                    </button>
                </form>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref } from "vue";

export default {
    name: "PlansCreate",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsPlansContract = inject("creatorsPlansContract");

        const buttonCreateWaiting = ref(false);

        const createPlan = async () => {
            const planName = document.querySelector('input[for="planName"]').value;
            const planDescription = document.querySelector('input[for="planDescription"]').value;
            const planExternalURL = document.querySelector('input[for="planExternalURL"]').value;
            const planDuration = document.querySelector('input[for="planDuration"]').value;
            const planPrice = document.querySelector('input[for="planPrice"]').value;
            const planUnits = document.querySelector('input[for="planUnits"]').value;
            try {
                buttonCreateWaiting.value = true;
                await creatorsPlansContract.value.methods.setPlan(planName, planDescription, planExternalURL, planDuration, planPrice, planUnits).send({ from: account.value });
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

            createPlan,
        };
    },
};
</script>
