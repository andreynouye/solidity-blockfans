import { ref } from 'vue';

export const account = ref(null);

export function isWalletConnected() {
    return account.value !== null;
}
