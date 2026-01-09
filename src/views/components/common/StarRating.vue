<template>
  <div class="star-rating">
    <i 
      v-for="star in 5" 
      :key="star"
      class="fa-star"
      :class="[
        star <= modelValue ? 'fa-solid active' : 'fa-regular',
        { 'editable': !readonly }
      ]"
      @click="updateRating(star)"
    ></i>
  </div>
</template>

<script setup>
const props = defineProps({
  modelValue: { type: Number, default: 0 },
  readonly: { type: Boolean, default: false }
});
const emit = defineEmits(['update:modelValue']);

const updateRating = (val) => {
  if (!props.readonly) {
    emit('update:modelValue', val);
  }
};
</script>

<style scoped>
.star-rating { display: inline-flex; gap: 5px; color: #fbbf24; font-size: 1.2rem; }
.active { color: #f59e0b; }
.editable { cursor: pointer; transition: transform 0.2s; }
.editable:hover { transform: scale(1.2); }
</style>