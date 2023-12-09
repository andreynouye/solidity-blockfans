<template>
    <AppHeader :web3="web3" :account="account" :isCreator="isCreator" :connectWallet="connectWallet" :disconnectWallet="disconnectWallet" />
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
        const LockeekAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
        const CreatorsAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
        const CreatorsNFTAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
        const CreatorsKeysAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

        const web3 = ref(null);
        const LockeekContract = ref(null);
        const creatorsContract = ref(null);
        const creatorsNFTContract = ref(null);
        const creatorsKeysContract = ref(null);
        const footer = ref(null);

        const isCreator = ref(false);

        const loadContracts = async () => {
            try {
                const responseLockeek = await fetch("/contracts/Lockeek.sol/Lockeek.json");
                const contractLockeek = await responseLockeek.json();
                const LockeekABI = contractLockeek.abi;

                const responseCreators = await fetch("/contracts/Creators.sol/Creators.json");
                const contractCreators = await responseCreators.json();
                const CreatorsABI = contractCreators.abi;

                const responseCreatorsNFT = await fetch("/contracts/CreatorsNFT.sol/CreatorsNFT.json");
                const contractCreatorsNFT = await responseCreatorsNFT.json();
                const CreatorsNFTABI = contractCreatorsNFT.abi;

                const responseCreatorsKeys = await fetch("/contracts/CreatorsKeys.sol/CreatorsKeys.json");
                const contractCreatorsKeys = await responseCreatorsKeys.json();
                const CreatorsKeysABI = contractCreatorsKeys.abi;

                LockeekContract.value = new web3.value.eth.Contract(LockeekABI, LockeekAddress);
                creatorsContract.value = new web3.value.eth.Contract(CreatorsABI, CreatorsAddress);
                creatorsNFTContract.value = new web3.value.eth.Contract(CreatorsNFTABI, CreatorsNFTAddress);
                creatorsKeysContract.value = new web3.value.eth.Contract(CreatorsKeysABI, CreatorsKeysAddress);
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

                        isCreator.value = await creatorsContract.value.methods.isCreator(account.value).call();
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

            LockeekContract.value = null;
            creatorsContract.value = null;
            creatorsNFTContract.value = null;
            creatorsKeysContract.value = null;

            router.push("/");
        };

        provide("web3", web3);
        provide("account", account);
        provide("footer", footer);

        provide("connectWallet", connectWallet);
        provide("disconnectWallet", disconnectWallet);

        provide("LockeekContract", LockeekContract);
        provide("creatorsContract", creatorsContract);
        provide("creatorsNFTContract", creatorsNFTContract);
        provide("creatorsKeysContract", creatorsKeysContract);

        return {
            web3,
            account,
            footer,

            LockeekContract,
            creatorsContract,
            creatorsNFTContract,
            creatorsKeysContract,

            isCreator,

            connectWallet,
            disconnectWallet,
        };
    },
};
</script>

<style lang="scss">
@import "./styles/global";
</style>
