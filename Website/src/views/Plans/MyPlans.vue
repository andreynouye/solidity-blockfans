<template>
    <div class="container">
        <div class="row justify-content-between">
            <div class="col-auto mr-auto">
                <h1>List Plans</h1>
                <ul v-if="plans.length > 0">
                    <li v-for="plan in plans" :key="plan.planId">
                        Plan: {{ plan }} ID: {{ plan.planId }}
                        <button v-if="plan.status == 0 || plan.status == 1" :id="'remove-' + plan.planId" @click="remove(plan.planId)">Remove</button>
                        <button v-if="plan.status == 3" :id="'restore-' + plan.planId" @click="restore(plan.planId)">Restore</button>
                        <button v-if="plan.status == 3" :id="'permanentRemove-' + plan.planId" @click="permanentRemove(plan.planId)">Permanent Remove</button>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, ref, onMounted } from "vue";

export default {
    name: "MyPlans",
    setup() {
        const web3 = inject("web3");
        const account = inject("account");

        const creatorsPlansContract = inject("creatorsPlansContract");

        const plans = ref([]);
        const loading = ref(true);

        const created = async () => {
            try {
                loading.value = true;
                const results = await creatorsPlansContract.value.methods.getPlanDetailsByCreator().call({ from: account.value });
                console.log("results:", results);
                const plansWithSales = [];
                for (const plan of results) {
                    try {
                        const salesCount = await creatorsPlansContract.value.methods.getSoldUnitsPerPlan(plan.planId).call();
                        plansWithSales.push({ ...plan, salesCount });
                    } catch (error) {
                        console.error("Error with Plan:", plan, error);
                    }
                }

                plans.value = plansWithSales.sort((a, b) => b.planId - a.planId);
            } catch (error) {
                console.error(error);
            } finally {
                loading.value = false;
            }
        };

        const remove = async (planId) => {
            try {
                await creatorsPlansContract.value.methods.deletePlan(planId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const permanentRemove = async (planId) => {
            try {
                await creatorsPlansContract.value.methods.permanentDeletePlan(planId).send({ from: account.value });
            } catch (error) {
                console.error(error);
            } finally {
                await created();
            }
        };

        const restore = async (planId) => {
            try {
                await creatorsPlansContract.value.methods.restorePlan(planId).send({ from: account.value });
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

            plans,
            loading,

            created,
            remove,
            permanentRemove,
            restore,
        };
    },
};
</script>
