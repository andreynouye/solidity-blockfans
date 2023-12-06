<template>
    <header>
        <div class="container">
            <div class="row justify-content-between">
                <div class="col-auto mr-auto">
                    <div class="logo">
                        <router-link to="/">
                            <h1 class="appName">Keek</h1>
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
                    <router-link to="/create">
                        <button>Create</button>
                    </router-link>
                    <router-link to="/list">
                        <button>List NFTs</button>
                    </router-link>
                    <router-link to="/owned">
                        <button>Owned NFTs</button>
                    </router-link>
                    <router-link to="/creators">
                        <button>List Creators</button>
                    </router-link>
                </div>
            </div>
        </div>
    </header>
</template>

<script>
export default {
    name: "AppHeader",
    props: ["web3", "account", "connectWallet", "disconnectWallet"],
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
