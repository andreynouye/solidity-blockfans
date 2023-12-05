import { createRouter, createWebHistory } from "vue-router";
import { isWalletConnected } from "./store.js";

import HomePage from "./views/HomePage.vue";
import CreateNFT from "./views/CreateNFT.vue";

const routes = [
    {
        path: "/",
        name: "HomePage",
        component: HomePage,
        meta: { title: "Welcome to BitMobster" },
    },
    {
        path: "/create",
        name: "Create",
        component: CreateNFT,
        meta: {
            requiresWallet: true,
            title: "Create",
        },
    },
];

const router = createRouter({
    history: createWebHistory(process.env.BASE_URL),
    routes,
});

router.beforeEach((to, from, next) => {
    if (to.meta.requiresWallet && !isWalletConnected()) {
        next({ name: "HomePage" });
    } else {
        next();
    }
});

router.afterEach((to) => {
    document.title = to.meta.title || "BitMobster";
});

export default router;
