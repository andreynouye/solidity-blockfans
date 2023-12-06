import { createRouter, createWebHistory } from "vue-router";
import { isWalletConnected } from "./store.js";

import HomePage from "./views/HomePage.vue";
import CreateNFT from "./views/CreateNFT.vue";
import ListNFT from "./views/ListNFT.vue";
import OwnedNFT from "./views/OwnedNFT.vue";
import CreatorsList from "./views/CreatorsList.vue";
import UserDetails from "./views/UserDetails.vue";

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
            title: "Create NFT",
        },
    },
    {
        path: "/list",
        name: "List",
        component: ListNFT,
        meta: {
            requiresWallet: true,
            title: "List NFTs",
        },
    },
    {
        path: "/owned",
        name: "Owned",
        component: OwnedNFT,
        meta: {
            requiresWallet: true,
            title: "Owned NFTs",
        },
    },
    {
        path: "/creators",
        name: "Creators",
        component: CreatorsList,
        meta: {
            requiresWallet: true,
            title: "Creators",
        },
    },
    {
        path: "/u/:username",
        name: "UserDetails",
        component: UserDetails,
        meta: {
            requiresWallet: true,
            title: "User Details",
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
    if (to.name === "UserDetails" && to.params.username) {
        document.title = `${to.params.username} - User Details | BitMobster`;
    } else {
        document.title = to.meta.title || "BitMobster";
    }
});

export default router;
