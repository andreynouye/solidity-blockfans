<template>
    <AppHeader :web3="web3" :account="account" :connectWallet="connectWallet" :disconnectWallet="disconnectWallet" />
    <router-view></router-view>
    <AppFooter ref="footer" />
</template>

<script>
import Web3 from "web3";
import { provide, ref } from "vue";
import { account } from "./store.js";
import router from "./router";
import AppHeader from "./components/AppHeader.vue";
import AppFooter from "./components/AppFooter.vue";

export default {
    router,
    components: {
        AppHeader,
        AppFooter,
    },
    setup() {
        const BlockfansAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";
        const CreatorsAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
        const CreatorsNFTAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";

        const web3 = ref(null);
        const blockFansContract = ref(null);
        const creatorsContract = ref(null);
        const creatorsNFTContract = ref(null);
        const footer = ref(null);

        const loadContracts = async () => {
            try {
                const responseBlockfans = await fetch("/contracts/IBlockfans.sol/IBlockfans.json");
                const contractBlockfans = await responseBlockfans.json();
                const BlockfansABI = contractBlockfans.abi;

                const responseCreators = await fetch("/contracts/ICreators.sol/ICreators.json");
                const contractCreators = await responseCreators.json();
                const CreatorsABI = contractCreators.abi;

                const responseCreatorsNFT = await fetch("/contracts/ICreatorsNFT.sol/ICreatorsNFT.json");
                const contractCreatorsNFT = await responseCreatorsNFT.json();
                const CreatorsNFTABI = contractCreatorsNFT.abi;

                blockFansContract.value = new web3.value.eth.Contract(BlockfansABI, BlockfansAddress);
                creatorsContract.value = new web3.value.eth.Contract(CreatorsABI, CreatorsAddress);
                creatorsNFTContract.value = new web3.value.eth.Contract(CreatorsNFTABI, CreatorsNFTAddress);

                console.log("creatorsNFTContract.value: ", creatorsNFTContract.value);
            } catch (error) {
                console.error(error);
            }
        };

        const connectWallet = async () => {
            if (window.ethereum) {
                try {
                    web3.value = new Web3(window.ethereum);
                    const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
                    account.value = accounts[0];

                    if (web3.value && account.value) {
                        account.value = accounts[0];
                        await loadContracts();
                    }
                } catch (error) {
                    console.error(error);
                }
            } else {
                alert("Por favor, instale o MetaMask ou um aplicativo similar para prosseguir");
            }
        };

        const disconnectWallet = () => {
            web3.value = null;
            account.value = null;

            blockFansContract.value = null;
            creatorsContract.value = null;
            creatorsNFTContract.value = null;

            router.push("/");
        };

        provide("web3", web3);
        provide("account", account);
        provide("footer", footer);

        provide("connectWallet", connectWallet);
        provide("disconnectWallet", disconnectWallet);

        provide("blockFansContract", blockFansContract);
        provide("creatorsContract", creatorsContract);
        provide("creatorsNFTContract", creatorsNFTContract);

        return {
            web3,
            account,
            footer,

            blockFansContract,
            creatorsContract,
            creatorsNFTContract,

            connectWallet,
            disconnectWallet,
        };
    },
};
</script>

<style lang="scss">
@import "./styles/global";
</style>
