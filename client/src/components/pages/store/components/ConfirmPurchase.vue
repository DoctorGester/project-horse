<template>
  <b-modal
    id="modal-confirm-purchase"
    ref="modal-confirm-purchase"
    centered
    hide-header
    hide-footer
  >
    Do you want to buy this item?
    <div class="mt-4 d-flex justify-content-end">
      <b-button class="mr-2" variant="secondary" @click="cancel"
        >Cancel</b-button
      >
      <b-button class="mr-2" variant="primary" @click="buy">Confirm</b-button>
    </div>
  </b-modal>
</template>

<script>
export default {
  props: {
    cosmetic: {},
  },
  methods: {
    buy() {
      const translationString = `cosmetics.${this.cosmetic.cosmetic_name}`;
      this.$bvToast.toast(
        `Added ${this.$i18n.t(translationString)} to your armory`,
        {
          title: `Notification`,
          toaster: "b-toaster-bottom-left",
          solid: true,
          appendToast: true,
        }
      );

      this.$refs["modal-confirm-purchase"].hide();
      this.$emit("buy", this.cosmetic);
    },
    cancel() {
      this.$refs["modal-confirm-purchase"].hide();
      this.$emit("cancel", this.cosmetic.cosmetic_id);
    },
  },
};
</script>

<style></style>
