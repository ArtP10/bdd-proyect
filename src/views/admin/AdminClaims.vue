<template>
  <div class="admin-claims-container">
    <h3>Gestión de Reclamos</h3>
    
    <div v-if="loading" class="loading"><i class="fa-solid fa-spinner fa-spin"></i></div>
    
    <table v-else class="styled-table">
        <thead>
            <tr>
                <th>Fecha</th>
                <th>Cliente</th>
                <th>Producto / Ticket</th>
                <th>Reclamo</th>
                <th>Estado</th>
                <th>Acción</th>
            </tr>
        </thead>
        <tbody>
            <tr v-for="c in claims" :key="c.id_reclamo">
                <td>{{ formatDate(c.fecha) }}</td>
                <td>{{ c.cliente }}</td>
                <td>
                    <div class="prod-name">{{ c.producto }}</div>
                    <small class="ticket-ref">{{ c.ticket_ref }}</small>
                    <div class="price-tag">${{ c.precio_ticket }}</div>
                </td>
                <td class="content-cell">{{ c.contenido }}</td>
                <td>
                    <span :class="['status-pill', c.estado.toLowerCase()]">{{ c.estado }}</span>
                </td>
                <td>
                    <button v-if="c.estado === 'Abierto'" class="btn-resolve" @click="openResolve(c)">
                        Resolver
                    </button>
                    <span v-else class="text-muted">Cerrado</span>
                </td>
            </tr>
        </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
        <div class="modal-box">
            <h3>Resolver Reclamo #{{ selectedClaim?.id_reclamo }}</h3>
            <p><strong>Problema:</strong> {{ selectedClaim?.contenido }}</p>
            
            <label>Respuesta al cliente:</label>
            <textarea v-model="responseText"></textarea>
            
            <div class="refund-section">
                <label class="checkbox-container">
                    <input type="checkbox" v-model="applyRefund">
                    <span class="checkmark"></span>
                    Reembolsar Ticket (${{ selectedClaim?.precio_ticket }})
                </label>
                <p v-if="applyRefund" class="refund-warning">
                    ⚠️ Se devolverá el 90% (${{ (selectedClaim?.precio_ticket * 0.9).toFixed(2) }}).
                    Esta acción es irreversible.
                </p>
            </div>

            <div class="modal-actions">
                <button class="btn-cancel" @click="showModal = false">Cancelar</button>
                <button class="btn-confirm" @click="submitResolution">Confirmar Resolución</button>
            </div>
        </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const claims = ref([]);
const loading = ref(true);
const showModal = ref(false);
const selectedClaim = ref(null);
const responseText = ref('');
const applyRefund = ref(false);

const loadClaims = async () => {
    loading.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/claims/all');
        const data = await res.json();
        if(data.success) claims.value = data.data;
    } catch(e) { console.error(e); }
    finally { loading.value = false; }
};

const openResolve = (c) => {
    selectedClaim.value = c;
    responseText.value = '';
    applyRefund.value = false;
    showModal.value = true;
};

const submitResolution = async () => {
    if(!responseText.value) return alert("Escribe una respuesta");
    if(applyRefund.value && !confirm("¿Confirmas el reembolso monetario?")) return;

    try {
        const res = await fetch('http://localhost:3000/api/claims/resolve', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                claim_id: selectedClaim.value.id_reclamo,
                response_text: responseText.value,
                refund: applyRefund.value
            })
        });
        const data = await res.json();
        if(data.success) {
            alert("Reclamo procesado correctamente");
            showModal.value = false;
            loadClaims();
        } else {
            alert("Error: " + data.message);
        }
    } catch(e) { console.error(e); }
};

const formatDate = (d) => new Date(d).toLocaleDateString();

onMounted(loadClaims);
</script>

<style scoped>
.admin-claims-container { padding: 20px; }
.styled-table { width: 100%; border-collapse: collapse; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
.styled-table th, .styled-table td { padding: 12px; border-bottom: 1px solid #ddd; text-align: left; }
.styled-table th { background: #f3f4f6; }
.content-cell { max-width: 300px; }
.status-pill { padding: 4px 8px; border-radius: 12px; font-size: 0.8rem; font-weight: bold; }
.status-pill.abierto { background: #fee2e2; color: #dc2626; }
.status-pill.cerrado { background: #dcfce7; color: #166534; }
.ticket-ref { font-family: monospace; color: #6b7280; display: block; }
.price-tag { color: #2563eb; font-weight: bold; }
.btn-resolve { background: #2563eb; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; }
.modal-box { background: white; padding: 25px; border-radius: 8px; width: 500px; }
textarea { width: 100%; height: 100px; margin: 10px 0; padding: 10px; border: 1px solid #ccc; }
.refund-section { background: #fff7ed; padding: 15px; border: 1px solid #ffedd5; margin-bottom: 20px; border-radius: 6px; }
.refund-warning { color: #c2410c; font-size: 0.9rem; margin-top: 5px; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; }
.btn-confirm { background: #16a34a; color: white; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; }
.btn-cancel { background: #e5e7eb; padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; }
</style>