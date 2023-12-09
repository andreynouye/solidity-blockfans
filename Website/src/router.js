import { createRouter, createWebHistory } from "vue-router";
import { isWalletConnected } from "./store.js";

import HomePage from "./views/HomePage.vue";

// Creators
import CreatorsList from "./views/Creators/List.vue";
import CreatorsProfile from "./views/Creators/Profile.vue";

// NFTs
import NFTsCreate from "./views/NFTs/Create.vue";
import MyNFTs from "./views/NFTs/MyNFTs.vue";
import OwnedNFTs from "./views/NFTs/OwnedNFTs.vue";

// Keys
import KeysCreate from "./views/Keys/Create.vue";
import MyKeys from "./views/Keys/MyKeys.vue";
import OwnedKeys from "./views/Keys/OwnedKeys.vue";

const routes = [
    {
        path: "/",
        name: "HomePage",
        component: HomePage,
        meta: { title: "Lockeek" },
    },
    {
        path: "/creators",
        name: "CreatorsList",
        component: CreatorsList,
        meta: {
            requiresWallet: true,
            title: "Creators",
        },
    },
    {
        path: "/u/:username",
        name: "CreatorsProfile",
        component: CreatorsProfile,
        meta: {
            requiresWallet: true,
            title: "User Details",
        },
    },
    {
        path: "/nfts",
        name: "MyNFTs",
        component: MyNFTs,
        meta: {
            requiresWallet: true,
            title: "List NFTs",
        },
    },
    {
        path: "/nfts/create",
        name: "NFTsCreate",
        component: NFTsCreate,
        meta: {
            requiresWallet: true,
            title: "Create NFT",
        },
    },
    {
        path: "/nfts/owned",
        name: "OwnedNFTs",
        component: OwnedNFTs,
        meta: {
            requiresWallet: true,
            title: "Owned NFTs",
        },
    },
    {
        path: "/keys",
        name: "MyKeys",
        component: MyKeys,
        meta: {
            requiresWallet: true,
            title: "List Keys",
        },
    },
    {
        path: "/keys/create",
        name: "KeysCreate",
        component: KeysCreate,
        meta: {
            requiresWallet: true,
            title: "Create Key",
        },
    },
    {
        path: "/keys/owned",
        name: "OwnedKeys",
        component: OwnedKeys,
        meta: {
            requiresWallet: true,
            title: "Owned Keys",
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
    if (to.name === "CreatorsProfile" && to.params.username) {
        document.title = `${to.params.username} - User Details | BitMobster`;
    } else {
        document.title = to.meta.title || "BitMobster";
    }
});

export default router;
