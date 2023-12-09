<template>
    <header>
        <div class="container">
            <div class="row justify-content-between">
                <div class="col-auto mr-auto">
                    <div class="logo">
                        <router-link to="/">
                            <h1 class="appName">Lockeek</h1>
                        </router-link>
                    </div>
                </div>
                <div class="col-auto d-md-none">
                    <button @click="showMenu = !showMenu" class="burgerMenu">Menu</button>
                </div>
                <div class="col-auto d-none d-md-flex">
                    <div class="primaryMenu">
                        <div v-if="!web3" class="connectWallet">
                            <button @click="connectWallet">Connect your wallet</button>
                        </div>
                        <div v-else class="connectedWallet">
                            <button v-if="account" @click="disconnectWallet">Disconnect ({{ account.slice(0, 6) }}*****{{ account.slice(-4) }})</button>
                            <button v-else @click="disconnectWallet">Loading...</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row justify-content-between">
                <div v-if="web3" class="secondaryMenu d-none d-md-flex">
                    <router-link to="/creators">
                        <button>List Creators</button>
                    </router-link>
                    <router-link to="/nfts" v-if="isCreator">
                        <button>My NFTs</button>
                    </router-link>
                    <router-link to="/nfts/create" v-if="isCreator">
                        <button>Create NFT</button>
                    </router-link>
                    <router-link to="/nfts/owned">
                        <button>Owned NFTs</button>
                    </router-link>
                    <router-link to="/keys" v-if="isCreator">
                        <button>My Keys</button>
                    </router-link>
                    <router-link to="/keys/create" v-if="isCreator">
                        <button>Create Key</button>
                    </router-link>
                    <router-link to="/keys/owned">
                        <button>Owned Keys</button>
                    </router-link>
                </div>
            </div>
        </div>
    </header>
</template>

<script>
export default {
    name: "AppHeader",
    props: ["web3", "account", "isCreator", "connectWallet", "disconnectWallet"],
    methods: {
        handleDisconnect() {
            this.disconnectWallet();
        },
        formatLargeNumbers: function (num) {
            if (num < 1000) {
                return num;
            }
            return num.toLocaleString("en-US");
        },
    },
};
</script>
