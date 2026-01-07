<template>
  <div class="cart-container">
    
    <div class="stepper-wrapper">
      <div class="stepper-item" :class="{ 'completed': currentStep > 1, 'active': currentStep === 1 }">
        <div class="step-counter">1</div>
        <div class="step-name">Viajeros</div>
      </div>
      <div class="stepper-item" :class="{ 'completed': currentStep > 2, 'active': currentStep === 2 }">
        <div class="step-counter">2</div>
        <div class="step-name">Itinerario</div>
      </div>
      <div class="stepper-item" :class="{ 'active': currentStep === 3 }">
        <div class="step-counter">3</div>
        <div class="step-name">Confirmación</div>
      </div>
    </div>

    <div v-if="currentStep === 1" class="step-content fade-in">
      <div class="section-header">
        <h3>¿Quiénes viajan?</h3>
        <p>Selecciona las personas para las que armarás este viaje.</p>
      </div>

      <div v-if="loading" class="loading-state">
        <i class="fa-solid fa-spinner fa-spin"></i> Cargando viajeros...
      </div>

      <div v-if="!loading && myTravelers.length === 0" class="empty-state">
        <i class="fa-solid fa-users-slash"></i>
        <p>No tienes viajeros registrados.</p>
        <button class="btn-link" @click="$router.push('/client/dashboard')">Ir a registrarlos</button>
      </div>

      <div v-if="!loading && myTravelers.length > 0" class="travelers-grid">
        <div 
          v-for="t in myTravelers" 
          :key="t.via_codigo" 
          class="traveler-card" 
          :class="{ selected: selectedTravelers.includes(t.via_codigo) }"
          @click="toggleTraveler(t.via_codigo)"
        >
          <div class="check-indicator" v-if="selectedTravelers.includes(t.via_codigo)">
            <i class="fa-solid fa-check-circle"></i>
          </div>
          <div class="avatar">
            {{ t.via_prim_nombre ? t.via_prim_nombre[0] : '' }}{{ t.via_prim_apellido ? t.via_prim_apellido[0] : '' }}
          </div>
          <div class="info">
            <strong>{{ t.via_prim_nombre }} {{ t.via_prim_apellido }}</strong>
            <small>DOC: {{ t.doc_numero_documento || 'N/A' }}</small> 
          </div>
        </div>
      </div>

      <div class="actions-footer">
        <div></div> 
        <button class="btn-next" :disabled="selectedTravelers.length === 0" @click="currentStep++">
          Siguiente <i class="fa-solid fa-arrow-right"></i>
        </button>
      </div>
    </div>

    <div v-if="currentStep === 2" class="step-content fade-in">
      <div class="section-header">
        <h3>Arma tu Itinerario</h3>
        <p>Busca y agrega servicios, traslados o paquetes completos.</p>
      </div>
      
      <div class="product-finder">
        <div class="finder-controls">
          <select v-model="selectedProductType" class="form-control type-select">
            <option value="servicio">Servicios / Actividades</option>
            <option value="traslado">Traslados / Vuelos</option>
            <option value="paquete">Paquetes Turísticos</option>
            <!-- OPCION DE WISHLIST PARA EL ITINERARIO -->
             <!--MELANIE -->
            <option value="wishlist">⭐ Mi Lista de Deseos</option>
            <!--------------------------->
          </select>
          
          <select v-model="selectedProduct" class="form-control product-select">
            <option :value="null" disabled>-- Seleccione una opción --</option>
            <option v-for="p in availableProducts" :key="p.id" :value="p">
              {{ p.nombre || p.descripcion }} - ${{ p.precio || p.costo }} 
              <span v-if="p.millas > 0"> (+{{ p.millas }} Millas)</span>
            </option>
          </select>
          
          <button class="btn-add" @click="addItemToCart" :disabled="!selectedProduct">
            <i class="fa-solid fa-plus"></i> Agregar
          </button>
        </div>
      </div>

      <div class="cart-list">
        <div v-if="cartItems.length === 0" class="empty-cart">
          Tu itinerario está vacío. ¡Agrega servicios arriba!
        </div>

        <div v-else class="cart-item" v-for="(item, idx) in cartItems" :key="idx">
          <div class="item-icon">
            <i :class="getIcon(item.tipo)"></i>
          </div>
          
          <div class="item-details">
            <div class="title-row">
                <h4>{{ item.nombre || item.descripcion }}</h4>
                <span v-if="item.millas > 0" class="badge-miles">
                    <i class="fa-solid fa-star"></i> +{{ item.millas * selectedTravelers.length }} Millas
                </span>
            </div>
            <span class="badge">{{ item.tipo }}</span>
            <div v-if="item.es_paquete" class="warning-text">
              <i class="fa-solid fa-circle-exclamation"></i> Aplica para todos los viajeros
            </div>
          </div>
          
          <div class="item-math">
            <div class="math-row">
                <span class="text-muted">Unitario:</span>
                <span>${{ item.precio || item.costo }}</span>
            </div>
            <div class="math-row">
                <span class="text-muted">Viajeros:</span>
                <span>x {{ selectedTravelers.length }}</span>
            </div>
            <div class="math-total">
                <strong>${{ ((item.precio || item.costo) * selectedTravelers.length).toFixed(2) }}</strong>
            </div>
          </div>

          <button class="btn-delete" @click="cartItems.splice(idx, 1)">
            <i class="fa-solid fa-trash-can"></i>
          </button>
        </div>
      </div>

      <div class="cart-summary-box">
        <div class="summary-row">
          <span>Subtotal:</span>
          <span>${{ cartTotal.toFixed(2) }}</span>
        </div>
        <div class="summary-row" style="color: #e91e63; font-weight: 600;">
          <span>Millas a ganar:</span>
          <span>+{{ totalMilesToEarn }} Millas</span>
        </div>
        <div class="summary-row total">
          <span>Total Estimado:</span>
          <span>${{ cartTotal.toFixed(2) }}</span>
        </div>
      </div>
      
      <div class="actions-footer">
        <button class="btn-back" @click="currentStep--">Atrás</button>
        <button class="btn-next" :disabled="cartItems.length === 0" @click="currentStep++">
          Ir a Confirmar <i class="fa-solid fa-check"></i>
        </button>
      </div>
    </div>

    <div v-if="currentStep === 3" class="step-content fade-in">
      <div class="section-header">
        <h3>Confirmación de Reserva</h3>
        <p>Elige tu modalidad de pago.</p>
      </div>
      
      <div class="payment-grid">
        <div class="payment-methods">
          <h4>Modalidad de Pago</h4>
          
          <label class="radio-card" :class="{ checked: paymentMode === 'contado' }">
            <input type="radio" v-model="paymentMode" value="contado">
            <div class="radio-content">
              <strong><i class="fa-solid fa-money-bill-1"></i> Pago de Contado</strong>
              <small>Paga el 100% hoy. Sin intereses.</small>
            </div>
            <div class="radio-price">${{ cartTotal.toFixed(2) }}</div>
          </label>

          <label class="radio-card" :class="{ checked: paymentMode === 'credito' }">
            <input type="radio" v-model="paymentMode" value="credito">
            <div class="radio-content">
              <strong><i class="fa-solid fa-credit-card"></i> Financiamiento</strong>
              <small>Inicial del 50% + Cuotas Mensuales (10% Interés)</small>
            </div>
            <div class="radio-price">Inicial: ${{ (cartTotal * 0.5).toFixed(2) }}</div>
          </label>

          <div v-if="paymentMode === 'credito'" class="dynamic-plan-selector fade-in">
            <label>Plazo de financiamiento:</label>
            <div class="range-wrapper">
                <input type="range" v-model.number="selectedMonths" min="3" max="12" step="1">
                <span class="range-value">{{ selectedMonths }} Meses</span>
            </div>
            
            <div class="finance-breakdown">
                <h5><i class="fa-solid fa-calculator"></i> Desglose del Plan</h5>
                <div class="breakdown-row"><span>Total Compra:</span> <span>${{ cartTotal.toFixed(2) }}</span></div>
                <div class="breakdown-row highlight"><span>Inicial a pagar hoy (50%):</span> <strong>${{ (cartTotal * 0.5).toFixed(2) }}</strong></div>
                <div class="breakdown-row"><span>Restante a financiar:</span> <span>${{ (cartTotal * 0.5).toFixed(2) }}</span></div>
                <div class="breakdown-row"><span>Interés Fijo (10%):</span> <span>+${{ (cartTotal * 0.5 * 0.10).toFixed(2) }}</span></div>
                <hr>
                <div class="breakdown-row total-quota">
                    <span>{{ selectedMonths }} Cuotas mensuales de:</span> 
                    <strong>${{ calculateQuota.toFixed(2) }}</strong>
                </div>
            </div>
          </div>
        </div>

        <div class="final-summary">
          <h4>Resumen de Orden</h4>
          <div class="summary-list">
             <div v-for="(item, i) in cartItems" :key="i" class="summary-item">
                <span class="item-name">
                    {{ item.nombre || item.descripcion }} 
                    <span class="qty-tag">x{{ selectedTravelers.length }}</span>
                </span>
                <span class="item-amount">${{ ((item.precio || item.costo) * selectedTravelers.length).toFixed(2) }}</span>
             </div>
          </div>
          <hr>
          <div class="total-big">
            <span>A Pagar Ahora:</span>
            <span>${{ amountToPayToday.toFixed(2) }}</span>
          </div>
          <div class="miles-earned">
             <i class="fa-solid fa-plane-departure"></i> Ganarás {{ totalMilesToEarn }} Millas
          </div>
          
          <button class="btn-confirm" @click="registerPurchase" :disabled="processing">
            <i v-if="processing" class="fa-solid fa-spinner fa-spin"></i> 
            {{ processing ? 'Procesando...' : 'Confirmar Reserva y Pagar' }}
          </button>
        </div>
      </div>

      <div class="actions-footer">
        <button class="btn-back" @click="currentStep--">Atrás</button>
      </div>
    </div>

    <PaymentModal 
        :is-open="showPaymentModal"
        :amount="paymentDetails.amount"
        :context="paymentDetails.type"
        :allow-miles="false" 
        @close="showPaymentModal = false"
        @payment-success="handlePaymentSuccess"
    />

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';
import PaymentModal from './PaymentModal.vue';

const router = useRouter();
const currentStep = ref(1);
const myTravelers = ref([]);
const selectedTravelers = ref([]);
const loading = ref(false);
const processing = ref(false);

const availableProducts = ref([]);
const selectedProductType = ref('servicio');
const selectedProduct = ref(null);
const cartItems = ref([]);

// NUEVO: Estado para Financiamiento Dinámico
const paymentMode = ref('contado'); // 'contado' o 'credito'
const selectedMonths = ref(3); // Por defecto 3 meses

const showPaymentModal = ref(false);
const paymentDetails = reactive({ amount: 0, type: '', id: 0 });
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

// --- CÁLCULOS ---
const cartTotal = computed(() => {
    return cartItems.value.reduce((acc, item) => {
        const price = parseFloat(item.precio || item.costo || 0);
        return acc + (price * selectedTravelers.value.length);
    }, 0);
});

const totalMilesToEarn = computed(() => {
    return cartItems.value.reduce((acc, item) => {
        const miles = parseInt(item.millas || 0); 
        return acc + (miles * selectedTravelers.value.length);
    }, 0);
});

const amountToPayToday = computed(() => {
    if (paymentMode.value === 'contado') return cartTotal.value;
    return cartTotal.value * 0.5; // Inicial 50%
});

const calculateQuota = computed(() => {
    if (paymentMode.value === 'contado') return 0;
    
    // Cálculo coincidente con SP: 50% financiado + 10% interés
    const financedAmount = cartTotal.value * 0.5;
    const interest = financedAmount * 0.10; 
    const totalDebt = financedAmount + interest;
    
    return totalDebt / selectedMonths.value;
});

// --- LÓGICA DE NEGOCIO ---

// 1. Registrar Compra (Solo genera la deuda/reserva)
const registerPurchase = async () => {
    processing.value = true;
    
    const itemsPayload = cartItems.value.map(i => ({ 
        tipo: i.tipo, 
        id: i.id || i.ser_codigo || i.tras_codigo || i.paq_tur_codigo 
    }));

    // Payload dinámico para el SP
    const planData = {
        plan: paymentMode.value, // 'contado' o 'credito'
        meses: paymentMode.value === 'credito' ? selectedMonths.value : null
    };

    const payload = {
        user_id: userSession.user_id,
        viajeros: selectedTravelers.value,
        items: itemsPayload,
        pago: planData
    };

    try {
        const res = await fetch('http://localhost:3000/api/cart/checkout', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            // EXITO REGISTRANDO -> AHORA ABRIMOS EL MODAL PARA PAGAR
            paymentDetails.amount = parseFloat(data.data.monto_pagar);
            paymentDetails.type = data.data.origen_tipo; // 'compra' o 'cuota'
            paymentDetails.id = data.data.origen_id;
            
            showPaymentModal.value = true;
        } else {
            alert('Error al registrar reserva: ' + data.message);
        }
    } catch(e) {
        alert('Error de conexión al registrar');
        console.error(e);
    } finally {
        processing.value = false;
    }
};

// 2. Procesar Pago (Cuando el modal emite 'payment-success')
const handlePaymentSuccess = async (paymentPayload) => {
    showPaymentModal.value = false;
    processing.value = true;

    try {
        const payload = {
            quota_id: paymentDetails.id, 
            origen: paymentDetails.type, // Clave para el backend
            pago: {
                metodo: paymentPayload.metodo,
                datos: paymentPayload.datos,
                moneda: paymentPayload.moneda
            },
            monto: paymentDetails.amount 
        };

        const res = await fetch('http://localhost:3000/api/payments/pay-quota', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();

        if(data.success) {
            alert('¡Pago procesado exitosamente!');
            router.push('/client/dashboard');
        } else {
            alert('Reserva creada, pero el pago falló: ' + data.message);
            router.push('/client/dashboard/payments'); 
        }

    } catch(e) {
        alert('Error de conexión al pagar.');
    } finally {
        processing.value = false;
    }
};

// --- CARGA DE DATOS ---
const loadTravelers = async () => {
    loading.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/list', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) {
            myTravelers.value = [...data.data];
        }
    } catch(e) { console.error(e); } finally { loading.value = false; }
};

const toggleTraveler = (id) => {
    if (selectedTravelers.value.includes(id)) {
        selectedTravelers.value = selectedTravelers.value.filter(t => t !== id);
    } else {
        selectedTravelers.value.push(id);
    }
};


// --- PASO 2: CARGA DINÁMICA DE PRODUCTOS ---
//--- CAMBIO DEL SELECT PARA QUE APAREZCA WISHLIST ---
//--- MELA ---// 
watch(selectedProductType, async (val) => {
    selectedProduct.value = null;
    availableProducts.value = [];
    let url = '';
    let options = { method: 'GET' };

    // Determinamos la URL
    if(val === 'servicio') url = 'http://localhost:3000/api/opciones/servicios'; 
    else if(val === 'traslado') url = 'http://localhost:3000/api/traslados-disponibles'; 
    else if(val === 'paquete') url = 'http://localhost:3000/api/paquetes';
    else if(val === 'wishlist') url = 'http://localhost:3000/api/cart/wishlist-items'; // Ruta de la compañera

    try {
        const res = await fetch(url, options);
        const data = await res.json();
        if(data.success) {
            availableProducts.value = data.data.map(item => ({
                ...item,
                // Fusión: Normalización de datos (Lista_Deseos) + Millas (Main)
                
                // 1. ID Unificado: Vital para que el v-model y las validaciones funcionen igual para todo
                id: item.id_original || item.id || item.ser_codigo || item.tras_codigo || item.paq_tur_codigo,
                
                // 2. Nombre y Precio unificados
                nombre: item.nombre || item.descripcion || item.paq_tur_nombre,
                precio: parseFloat(item.precio || item.costo || item.paq_tur_monto_total || 0),
                
                // 3. Tipo Real: Si viene de wishlist, el item ya trae su tipo ('servicio', 'paquete').
                // Si es búsqueda normal, usamos el valor del select (val).
                tipo: item.tipo || val,

                // 4. Millas (De tu rama Main): Aseguramos que no se pierda este beneficio
                millas: parseInt(item.millas || item.ser_millas_otorgadas || item.rut_millas_otorgadas || 0)
            }));
        }
    } catch(e) { console.error("Error cargando productos:", e); }
});
//--------------------------------------------------------------
//Asegurar que el icono se asigne correctamente según el tipo real del producto (especialmente si viene de la wishlist)
const addItemToCart = () => {
    if(!selectedProduct.value) return;
    
    // Obtenemos el tipo real del objeto (crucial para wishlist que mezcla cosas)
    const tipoReal = selectedProduct.value.tipo;
    const productId = selectedProduct.value.id;

    // Validación de duplicados (Lógica de Main mejorada con IDs normalizados)
    const exists = cartItems.value.find(item => {
        return item.id === productId && item.tipo === tipoReal;
    });

    if (exists) { 
        alert('Este ítem ya está en el carrito.'); 
        return; 
    }

    // Agregar al carrito
    cartItems.value.push({
        ...selectedProduct.value,
        tipo: tipoReal, // Usamos el tipo real, no el del select (por si es wishlist)
        es_paquete: tipoReal === 'paquete' // Flag auxiliar para UI
    });
    
    selectedProduct.value = null;
};
//----------

const getIcon = (tipo) => {
    if(tipo === 'servicio') return 'fa-solid fa-ticket';
    if(tipo === 'traslado') return 'fa-solid fa-plane';
    if(tipo === 'paquete') return 'fa-solid fa-box-open';
    return 'fa-solid fa-star';
};

onMounted(() => {
    if(userSession.user_id) {
        loadTravelers();
        selectedProductType.value = 'servicio'; 
    } else {
        router.push('/login');
    }
});
</script>

<style scoped>
/* Estilos Base */
.cart-container { max-width: 900px; margin: 40px auto; font-family: 'Segoe UI', sans-serif; color: #333; }
.stepper-wrapper { display: flex; justify-content: space-between; margin-bottom: 40px; position: relative; }
.stepper-wrapper::before { content: ''; position: absolute; top: 15px; left: 0; width: 100%; height: 2px; background: #e0e0e0; z-index: 0; }
.stepper-item { position: relative; z-index: 1; text-align: center; background: #fff; padding: 0 10px; }
.step-counter { width: 35px; height: 35px; border-radius: 50%; background: #fff; border: 2px solid #ccc; color: #ccc; display: flex; align-items: center; justify-content: center; font-weight: bold; margin: 0 auto 5px; }
.step-name { font-size: 0.85rem; color: #999; font-weight: 600; }
.stepper-item.active .step-counter { border-color: #3b82f6; color: #3b82f6; }
.stepper-item.active .step-name { color: #3b82f6; }
.stepper-item.completed .step-counter { background: #3b82f6; border-color: #3b82f6; color: white; }
.stepper-item.completed .step-name { color: #333; }

.step-content { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
.section-header { margin-bottom: 25px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
.section-header h3 { margin: 0 0 5px 0; font-size: 1.5rem; color: #1e293b; }

/* Grid de Viajeros */
.travelers-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 15px; margin-bottom: 30px; }
.traveler-card { border: 2px solid #f1f5f9; border-radius: 10px; padding: 15px; display: flex; align-items: center; gap: 15px; cursor: pointer; position: relative; transition: all 0.2s; }
.traveler-card:hover { border-color: #cbd5e1; }
.traveler-card.selected { border-color: #3b82f6; background: #eff6ff; }
.avatar { width: 45px; height: 45px; background: #e2e8f0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; color: #64748b; }
.traveler-card.selected .avatar { background: #3b82f6; color: white; }
.check-indicator { position: absolute; top: 10px; right: 10px; color: #3b82f6; }

/* Buscador */
.product-finder { background: #f8fafc; padding: 20px; border-radius: 8px; margin-bottom: 25px; }
.finder-controls { display: flex; gap: 10px; }
.form-control { padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; flex: 1; }
.btn-add { background: #10b981; color: white; border: none; padding: 0 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }
.btn-add:disabled { background: #94a3b8; cursor: not-allowed; }

/* Lista Carrito (CON TUS DETALLES VISUALES) */
.cart-list { border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 20px; }
.cart-item { display: flex; align-items: center; padding: 15px; border-bottom: 1px solid #f1f5f9; }
.item-icon { font-size: 1.2rem; color: #64748b; margin-right: 15px; width: 40px; text-align: center; }
.item-details { flex: 1; }
.title-row { display: flex; align-items: center; gap: 10px; margin-bottom: 5px; }
.badge { background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
.badge-miles { background: #fffbeb; color: #d97706; padding: 2px 8px; border-radius: 12px; font-size: 0.75rem; font-weight: 700; border: 1px solid #fcd34d; }
.warning-text { color: #f59e0b; font-size: 0.8rem; margin-top: 2px; }

/* Estilos de Precio Unitario y Totales */
.item-math { text-align: right; min-width: 140px; font-size: 0.9rem; }
.math-row { display: flex; justify-content: space-between; color: #333; margin-bottom: 2px; }
.text-muted { color: #64748b; font-size: 0.85rem; }
.math-total { border-top: 1px solid #e2e8f0; margin-top: 4px; padding-top: 4px; font-size: 1.1rem; color: #1e293b; }

.btn-delete { color: #ef4444; background: none; border: none; cursor: pointer; margin-left: 15px; font-size: 1.1rem; }
.btn-delete:hover { color: #dc2626; }

/* Resumen */
.cart-summary-box { background: #f8fafc; padding: 20px; border-radius: 8px; text-align: right; }
.summary-row { display: flex; justify-content: space-between; margin-bottom: 5px; }
.summary-row.total { font-size: 1.3rem; font-weight: 800; margin-top: 10px; border-top: 1px solid #ddd; padding-top: 10px; }

/* Pago Dinámico */
.payment-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; }
.radio-card { display: flex; align-items: center; border: 2px solid #f1f5f9; padding: 15px; border-radius: 8px; margin-bottom: 10px; cursor: pointer; justify-content: space-between; transition: all 0.2s; }
.radio-card:hover { border-color: #cbd5e1; }
.radio-card.checked { border-color: #3b82f6; background: #eff6ff; }
.radio-card input { display: none; }

.dynamic-plan-selector { background: #f8fafc; padding: 20px; border-radius: 8px; border: 1px solid #e2e8f0; margin-top: 15px; }
.range-wrapper { display: flex; align-items: center; gap: 15px; margin: 15px 0; }
input[type=range] { flex: 1; accent-color: #3b82f6; }
.range-value { background: #3b82f6; color: white; padding: 2px 8px; border-radius: 12px; font-size: 0.85rem; font-weight: bold; }

.finance-breakdown { background: #fffbeb; border: 1px solid #fcd34d; padding: 15px; border-radius: 8px; font-size: 0.9rem; margin-top: 15px; }
.finance-breakdown h5 { margin: 0 0 10px 0; color: #b45309; }
.breakdown-row { display: flex; justify-content: space-between; margin-bottom: 5px; }
.breakdown-row.highlight { font-weight: 700; color: #b45309; }
.breakdown-row.total-quota { font-size: 1.1rem; color: #1e293b; margin-top: 5px; border-top: 1px dashed #d97706; padding-top: 5px; font-weight: bold; }

.final-summary { background: #f8fafc; padding: 20px; border-radius: 8px; height: fit-content; }
.summary-item { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 0.9rem; border-bottom: 1px dashed #e2e8f0; padding-bottom: 5px; }
.qty-tag { background: #e2e8f0; color: #475569; padding: 1px 6px; border-radius: 4px; font-size: 0.75rem; font-weight: bold; margin-left: 5px; }
.total-big { display: flex; justify-content: space-between; font-size: 1.2rem; font-weight: 800; margin: 15px 0; color: #1e293b; }
.miles-earned { text-align: center; background: #ec4899; color: white; padding: 8px; border-radius: 6px; margin: 15px 0; font-weight: 700; }
.btn-confirm { width: 100%; background: #3b82f6; color: white; padding: 12px; border-radius: 6px; border: none; font-weight: 700; cursor: pointer; transition: background 0.2s; }
.btn-confirm:hover { background: #2563eb; }
.btn-confirm:disabled { background: #94a3b8; cursor: not-allowed; }

.actions-footer { display: flex; justify-content: space-between; margin-top: 30px; }
.btn-next { background: #1e293b; color: white; padding: 10px 25px; border-radius: 6px; border: none; cursor: pointer; font-weight: 600; }
.btn-back { background: transparent; border: 1px solid #cbd5e1; padding: 10px 25px; border-radius: 6px; cursor: pointer; font-weight: 600; }
</style>