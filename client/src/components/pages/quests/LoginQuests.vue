<template>
  <div
    style="background-color: #2d223b; border: solid 1.1px #403652"
    class="pb-2"
  >
    <div class="d-flex justify-content-between px-3 py-3">
      <span>Login ({{ numCompleted }}/7)</span>
      <!-- <span>{{ daysUntilMonday }} day(s) left</span> -->
    </div>
    <div
      v-if="loading"
      class="d-flex justify-content-between"
      style="overflow-x: auto"
    >
      <div
        v-for="i in 7"
        :key="i"
        class="mx-3 single-quest"
        style="width: 125px"
      >
        <div style="height: 48px"></div>
        <div class="quest-xp" style="height: 27px"></div>
      </div>
    </div>
    <div
      v-if="!loading"
      class="d-flex justify-content-between"
      style="overflow-x: auto"
    >
      <div
        v-for="quest in quests"
        :key="quest.login_quest_id"
        class="mx-3 single-quest"
      >
        <div v-if="quest.claimed" class="overlay"></div>
        <div style="height: 115px">
          <div class="quest-xp-text text-center p-3" v-if="quest.xp_reward > 0">
            {{ quest.xp_reward }} {{ $t("common.xp") }}
          </div>
          <div class="pog-text text-center p-3" v-if="quest.coin_reward > 0">
            {{ quest.coin_reward }} {{ $t("common.coins") }}
          </div>
          <img
            style="height: 100%; width: 100%; object-fit: cover"
            v-if="quest.cosmetic_name"
            v-bind:src="cosmeticImageSrc(quest)"
            :alt="quest.cosmetic_name"
          />
        </div>
        <div class="text-center quest-xp py-1">
          Day {{ quest.day }}
          <i v-if="quest.claimed" class="fas fa-check ml-1"></i>
        </div>
        <div class="text-center">
          <button
            v-on:click="claimQuest(quest)"
            v-if="quest.completed && !quest.claimed"
            type="button"
            class="btn btn-primary mt-2"
          >
            Claim
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({
    error: "",
    showError: false,
    quests: [],
    loading: true,
    numCompleted: 0,
    daysUntilMonday: 0,
  }),

  created() {
    this.getLoginQuests();
    // this.tryComplete();

    this.daysUntilMonday = this.getDaysUntilMonday();
  },

  methods: {
    getDaysUntilMonday() {
      const today = new Date();
      const day = today.getDay();
      const diff = (day < 1 ? 7 : 0) + 1 - day;

      return 7 + diff;
    },
    getLoginQuests() {
      fetch(`/api/players/${this.$store.state.auth.userSteamID}/login_quests`)
        .then(
          (res) => res.json(),
          (err) => {
            this.error = err;
            this.showError = true;
            console.error(err);
          }
        )
        .then((quests) => {
          this.loading = false;
          this.quests = quests;
          this.numCompleted = quests.filter((quest) => quest.completed).length;
        })
        .catch((err) => {
          this.error = err;
          this.showError = true;
        });
    },
    tryComplete() {
      fetch(
        `/api/players/${this.$store.state.auth.userSteamID}/login_quests/try_complete`,
        { method: "post" }
      )
        .then((res) => res.json())
        .then((completed) => {
          if (completed) this.getLoginQuests();
        });
    },
    claimQuest(quest) {
      const { login_quest_id } = quest;
      this.quests = this.quests.map((q) =>
        q.login_quest_id === login_quest_id ? { ...q, claimed: true } : q
      );
      fetch(
        `/api/players/${this.$store.state.auth.userSteamID}/login_quests/claim?questID=${login_quest_id}`,
        { method: "post" }
      )
        .then((res) => res.json())
        .then(() => {
          this.getLoginQuests();
          this.$store.dispatch("REFRESH_BATTLE_PASS");
          this.$store.dispatch("REFRESH_PLAYER");
        })
        .catch((err) => {
          this.error = err;
          this.showError = true;
        });
    },
    cosmeticImageSrc(cosmetic) {
      const { cosmetic_name } = cosmetic;
      return `/images/cosmetics/${cosmetic_name}.png`;
    },
  },
};
</script>

<style scoped>
.single-quest {
  /* border: solid 1px #202e3a; */
  border: solid 1.1px #403652;
  background-color: #2d223b;
  border-bottom: 0;
  min-width: 125px;
  position: relative;
}

.quest-xp {
  background-color: #1f1a2b;
  border: solid 1.1px #403652;
  border-top: 0;
  border-bottom: 3px solid #3c1278;
}

.overlay {
  position: absolute;
  top: 0;
  background-color: #403652;
  opacity: 0.5;
  width: 100%;
  height: 100%;
}
</style>