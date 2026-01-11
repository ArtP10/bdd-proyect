<template>
  <div class="my-reviews-container fade-in">
    <h3><i class="fa-solid fa-comment-dots"></i> Mis Reseñas Realizadas</h3>
    
    <div v-if="loading" class="loading-state">
        <i class="fa-solid fa-spinner fa-spin"></i> Cargando...
    </div>

    <div v-else-if="reviews.length === 0" class="empty-state">
        <p>Aún no has escrito reseñas. ¡Viaja y cuéntanos tu experiencia!</p>
    </div>

    <div v-else class="reviews-list">
        <div v-for="r in reviews" :key="r.res_id" class="review-item">
            <div class="review-header">
                <span class="product-name">{{ r.producto_nombre }}</span>
                <span class="product-type">{{ r.tipo_producto }}</span>
            </div>
            <div class="rating-row">
                <StarRating :modelValue="r.calificacion" :readonly="true" />
                <span class="date">{{ formatDate(r.fecha) }}</span>
            </div>
            <p class="review-text">"{{ r.comentario }}"</p>
            <div class="traveler-tag">
                <small><i class="fa-solid fa-user"></i> Viajero: {{ r.viajero }}</small>
            </div>
        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import StarRating from '../components/common/StarRating.vue'; // Ajusta ruta

const props = defineProps(['userId']);
const reviews = ref([]);
const loading = ref(true);

const formatDate = (d) => new Date(d).toLocaleDateString();

onMounted(async () => {
    try {
        const res = await fetch(`http://localhost:3000/api/reviews/user/${props.userId}`);
        const data = await res.json();
        if(data.success) reviews.value = data.data;
    } catch(e) { console.error(e); }
    finally { loading.value = false; }
});
</script>

<style scoped>
.my-reviews-container { padding: 20px; }
.review-item { background: white; padding: 20px; border-radius: 12px; margin-bottom: 15px; border: 1px solid #e5e7eb; }
.review-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
.product-name { font-weight: 700; color: #1f2937; }
.product-type { font-size: 0.8rem; background: #eff6ff; color: #3b82f6; padding: 2px 8px; border-radius: 4px; }
.review-text { font-style: italic; color: #4b5563; margin: 10px 0; }
.date { font-size: 0.85rem; color: #9ca3af; margin-left: 10px; }
.traveler-tag { color: #6b7280; font-size: 0.85rem; }
</style>