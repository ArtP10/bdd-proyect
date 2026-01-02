<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-card slide-up">
      <div class="modal-header">
        <h3>Detalle de la Compra #{{ compraId }}</h3>
        <button class="close-btn" @click="close">×</button>
      </div>

      <div class="modal-body">
        <div v-if="loading" class="text-center">
            <i class="fa-solid fa-spinner fa-spin"></i> Cargando detalles...
        </div>
        
        <div v-else-if="items.length === 0" class="empty-state">
            No se encontraron items asociados.
        </div>

        <div v-else class="items-list">
            <div v-for="(item, idx) in items" :key="idx" class="item-row">
                <div class="icon-box" :class="item.tipo.toLowerCase()">
                    <i :class="getIcon(item.tipo)"></i>
                </div>
                <div class="item-info">
                    <h4>{{ item.nombre }}</h4>
                    <div class="meta">
                        <span v-if="item.fecha !== 'N/A'"><i class="fa-regular fa-calendar"></i> {{ item.fecha }}</span>
                        <span>{{ item.detalle }}</span>
                    </div>
                </div>
                <div class="item-tag">{{ item.tipo }}</div>
            </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-close" @click="close">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps(['isOpen', 'compraId']);
const emit = defineEmits(['close']);
const items = ref([]);
const loading = ref(false);

const getIcon = (tipo) => {
    if(tipo === 'Servicio') return 'fa-solid fa-ticket';
    if(tipo === 'Traslado') return 'fa-solid fa-plane';
    return 'fa-solid fa-box-open';
};

const fetchItems = async () => {
    if(!props.compraId) return;
    
    console.log("Consultando items para compra ID:", props.compraId); // <-- Debug: Ver qué enviamos
    
    loading.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/payments/items', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ compra_id: props.compraId })
        });
        
        // Manejo de error HTTP
        if (!res.ok) {
            const errorText = await res.text();
            console.error("Error del servidor:", errorText);
            alert("Error al cargar detalles: " + res.status);
            return;
        }

        const data = await res.json();
        if(data.success) items.value = data.data;
    } catch(e) { 
        console.error(e); 
    } finally { 
        loading.value = false; 
    }
};

watch(() => props.isOpen, async (newVal) => {
    // Solo buscamos si el modal se abre Y tenemos un ID válido
    if(newVal && props.compraId) {
        await fetchItems();
    }
});

const close = () => emit('close');
</script>

<style scoped>
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 2000; }
.modal-card { background: white; width: 90%; max-width: 500px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); animation: slideUp 0.3s ease-out; }
.modal-header { background: #f8fafc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
.modal-body { padding: 20px; max-height: 60vh; overflow-y: auto; }
.items-list { display: flex; flex-direction: column; gap: 10px; }

.item-row { display: flex; align-items: center; gap: 15px; padding: 10px; border: 1px solid #f1f5f9; border-radius: 8px; transition: background 0.2s; }
.item-row:hover { background: #f8fafc; }

.icon-box { width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 8px; color: white; }
.icon-box.servicio { background: #10b981; }
.icon-box.traslado { background: #3b82f6; }
.icon-box.paquete { background: #8b5cf6; }

.item-info { flex: 1; }
.item-info h4 { margin: 0 0 5px 0; font-size: 0.95rem; color: #334155; }
.meta { display: flex; gap: 10px; font-size: 0.75rem; color: #64748b; }

.item-tag { font-size: 0.7rem; font-weight: bold; color: #94a3b8; text-transform: uppercase; }
.modal-footer { padding: 15px; border-top: 1px solid #e2e8f0; text-align: right; }
.btn-close { padding: 8px 16px; background: #e2e8f0; border: none; border-radius: 6px; cursor: pointer; color: #475569; font-weight: 600; }
.close-btn { background: none; border: none; font-size: 1.5rem; cursor: pointer; }

@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
</style>