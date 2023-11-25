<template>
  <q-page>
    <q-card v-if="user" class="q-pa-md">

      <q-card-section>
        <div class="row  justify-center">
          <div class="col-auto">
            <qrcode-stream @detect="onDetect"></qrcode-stream>
          </div>
        </div>
      </q-card-section>
      <q-card-section>
        <div class="row justify-center">
          <div class="col-auto">Scanned bottle: {{ scannedBottleId }}</div>
        </div>
      </q-card-section>
      <q-card-section>
        <div class="row justify-center">
          <div class="col-auto" v-if="currentBottle">
            <q-select label="Choose Batch" :options="batches" v-model="currentBottle.batch_id" map-options emit-value @update:model-value="updateBottle"/>
          </div>
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script>
import {defineComponent, onMounted, ref} from "vue";
import {QrcodeStream} from "vue-qrcode-reader";
import userAuthUser from "../composables/UserAuthUser";
import {createClient} from '@supabase/supabase-js'

export default defineComponent({
  name: "IndexPage",
  components: {
    QrcodeStream,
  },
  setup() {
    const supabase = createClient('https://uebxqgvgvzwmqvubrgec.supabase.co', 'key goes here')
    const {user} = userAuthUser();
    const scannedBottleId = ref(null);
    const batches = ref([]);
    const currentBottle = ref(undefined);
    const selectedBatch = ref('empty bottle');

    const onDetect = async (result) => {
      let res = await result
      scannedBottleId.value = res.content;
      await getOrCreateBottle(scannedBottleId.value)
    };

    const getOrCreateBottle = async (bottleId) => {
      const {data, error} = await supabase
        .from('bottle')
        .select()
        .eq('id', bottleId)

      if (error == null) {
        if (data.length == 0) {
          let newBottle = {id: bottleId}
          const {data, error} = await supabase
            .from('bottle')
            .insert(newBottle)
          if (error == null) {
            currentBottle.value = newBottle
          } else {
            console.log(error)
          }
        } else {
          currentBottle.value = data[0]
        }
      } else {
        console.log(error)
      }
    }

    const upsertBatch = async (batchNo) => {
      let recipeName = findBatchRecipeName(batchNo)
      const {data, error} = await supabase
        .from('batch')
        .upsert({id: batchNo, name: recipeName})
        .eq('id', batchNo)
      if (error != null) {
        console.log(error)
      }
    }

    const findBatchRecipeName = (batchNo) => {
      return batches.value.find(b => b.value == batchNo).label
    }

    const updateBottle = async (batch_id) => {
      await upsertBatch(batch_id)
      const {data, error} = await supabase
        .from('bottle')
        .update({batch_id: batch_id})
        .eq('id', currentBottle.value.id)
      if (error != null) {
        console.log(error)
      }
    }


    onMounted(() => {
      fetch("https://api.brewfather.app/v2/batches?order_by=batchNo&order_by_direction=desc", {
        headers: new Headers({
          "Authorization": `Basic ${btoa('breweryid goes here:key goes here')}`
        }),
      }).then(async response => {
        if (!response.ok) throw new Error(response.status);
        let b = await response.json();
        batches.value = b.map(bb => {
          return {
            value: bb.batchNo,
            label: bb.recipe.name,
          }
        });
      })
    })

    return {
      batches,
      currentBottle,
      selectedBatch,
      updateBottle,
      camera: 'auto',
      result: null,
      showScanConfirmation: false,
      user,
      scannedBottleId,
      onDetect,
    };
  },
});
</script>
<style>
video {
  width: 180px;
  display: flow;
}

canvas {
  display: none;
}
</style>
