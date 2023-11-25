<template>
  <q-layout view="hHh lpR fFf">

    <q-page-container>
      <router-view />
    </q-page-container>

  </q-layout>
</template>
<script>
import { defineComponent, ref } from "vue";
import { useRouter } from "vue-router";

import userAuthUser from "../composables/UserAuthUser";
import useNotify from "src/composables/UseNotify";
import useDialog from "src/composables/UseDialog";

const linksList = [
  {
    title: "Github",
    caption: "github.com/quasarframework",
    icon: "code",
    link: "https://github.com/quasarframework",
  },
];

export default defineComponent({
  name: "MainLayout",

  components: {
  },

  setup() {

    const handlerLogout = async () => {
      dialogShow({
        tittle: "Logout",
        message: "Do you really want to logout?",
      })
        .onOk(async () => {
          try {
            await logout();
            notifySuccess("Bye bye! 😁");
            router.replace({
              name: "login",
            });
          } catch (error) {
            notifyError(error.message);
          }
          /** o replace elimina o histórico de rotas, diferente
           * do push, que adicionar na pilha de histórico
           */
        })
        .onCancel(async () => {
          notifySuccess("Ops, ia mas voltou! 😁");
        });
    };

    return {
      handlerLogout,
    };
  },
});
</script>
