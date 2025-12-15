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
        <div class="step-name">Pago</div>
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

      <div v-else-if="myTravelers.length === 0" class="empty-state">
        <i class="fa-solid fa-users-slash"></i>
        <p>No tienes viajeros registrados.</p>
        <button class="btn-link" @click="$router.push('/client/dashboard')">Ir a registrarlos</button>
      </div>

      <div v-else class="travelers-grid">
        <div 
          v-for="t in myTravelers" 
          :key="t.via_codigo" 
          class="traveler-card" 
          :class="{ selected: selectedTravelers.includes(t.via_codigo) }"
          @click="toggleTraveler(t.via_codigo)"
        >
          <div class="check-indicator">
            <i class="fa-solid fa-check"></i>
          </div>
          <div class="avatar">{{ t.via_prim_nombre[0] }}{{ t.via_prim_apellido[0] }}</div>
          <div class="info">
            <strong>{{ t.via_prim_nombre }} {{ t.via_prim_apellido }}</strong>
            <small>DOC: {{ t.via_codigo }}</small> </div>
        </div>
      </div>

      <div class="actions-footer">
        <div></div> <button class="btn-next" :disabled="selectedTravelers.length === 0" @click="currentStep++">
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
          </select>
          
          <select v-model="selectedProduct" class="form-control product-select">
            <option :value="null" disabled>-- Seleccione una opción --</option>
            <option v-for="p in availableProducts" :key="p.id" :value="p">
              {{ p.nombre || p.descripcion }} - ${{ p.precio || p.costo }}
            </option>
          </select>
          
          <button class="btn-add" @click="addItemToCart" :disabled="!selectedProduct">
            <i class="fa-solid fa-plus"></i> Agregar
          </button>
        </div>
      </div>

      <div class="cart-list">
        <div v-if="cartItems.length === 0" class="empty-cart">
          Tu itinerario está vacío. ¡Agrega algo arriba!
        </div>

        <div v-else class="cart-item" v-for="(item, idx) in cartItems" :key="idx">
          <div class="item-icon">
            <i :class="getIcon(item.tipo)"></i>
          </div>
          <div class="item-details">
            <h4>{{ item.nombre || item.descripcion }}</h4>
            <span class="badge">{{ item.tipo }}</span>
            <div v-if="item.es_paquete" class="warning-text">
              <i class="fa-solid fa-circle-exclamation"></i> Aplican reglas de edad/cantidad
            </div>
          </div>
          
          <div class="item-quantity">
            <label>Viajeros</label>
            <div class="qty-display">{{ selectedTravelers.length }}</div>
          </div>

          <div class="item-price">
            <div class="unit-price">${{ item.precio || item.costo }} c/u</div>
            <div class="total-price">${{ ((item.precio || item.costo) * selectedTravelers.length).toFixed(2) }}</div>
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
        <div class="summary-row total">
          <span>Total Estimado:</span>
          <span>${{ cartTotal.toFixed(2) }}</span>
        </div>
      </div>
      
      <div class="actions-footer">
        <button class="btn-back" @click="currentStep--">Atrás</button>
        <button class="btn-next" :disabled="cartItems.length === 0" @click="currentStep++">
          Ir a Pagar <i class="fa-solid fa-credit-card"></i>
        </button>
      </div>
    </div>

    <div v-if="currentStep === 3" class="step-content fade-in">
      <div class="section-header">
        <h3>Confirmación y Pago</h3>
        <p>Elige cómo quieres pagar tu viaje.</p>
      </div>
      
      <div class="payment-grid">
        <div class="payment-methods">
          <h4>Plan de Pago</h4>
          <label class="radio-card" :class="{ checked: !isFinanced }">
            <input type="radio" v-model="isFinanced" :value="false">
            <div class="radio-content">
              <strong>Pago de Contado</strong>
              <small>Pagar el 100% hoy (${{ cartTotal.toFixed(2) }})</small>
            </div>
            <i class="fa-solid fa-circle-check" v-if="!isFinanced"></i>
          </label>

          <label class="radio-card" :class="{ checked: isFinanced }">
            <input type="radio" v-model="isFinanced" :value="true">
            <div class="radio-content">
              <strong>Financiamiento (4 Meses)</strong>
              <small>50% Inicial + 4 cuotas mensuales (10% interés)</small>
            </div>
            <i class="fa-solid fa-circle-check" v-if="isFinanced"></i>
          </label>

          <div v-if="isFinanced" class="finance-breakdown">
            <div class="breakdown-row"><span>Inicial a pagar hoy:</span> <strong>${{ (cartTotal * 0.5).toFixed(2) }}</strong></div>
            <div class="breakdown-row"><span>4 Cuotas mensuales de:</span> <strong>${{ ((cartTotal * 0.5 * 1.10) / 4).toFixed(2) }}</strong></div>
          </div>

          <h4 class="mt-4">Método de Pago</h4>
          <select v-model="paymentMethod" class="form-control mb-3">
            <option value="zelle">Zelle</option>
            <option value="tarjeta">Tarjeta de Crédito / Débito</option>
            <option value="movil">Pago Móvil</option>
          </select>

          <div class="dynamic-form">
             <div v-if="paymentMethod === 'zelle'">
                <input v-model="paymentData.correo" placeholder="Correo Zelle" class="form-control mb-2">
                <input v-model="paymentData.titular" placeholder="Titular Cuenta" class="form-control mb-2">
                <input v-model="paymentData.referencia" placeholder="# Referencia" class="form-control">
             </div>
             <div v-if="paymentMethod === 'tarjeta'">
                <input v-model="paymentData.numero" placeholder="Número de Tarjeta" class="form-control mb-2">
                <div class="row-2">
                    <input v-model="paymentData.vencimiento" type="month" placeholder="MM/YY" class="form-control">
                    <input v-model="paymentData.cvv" placeholder="CVV" maxlength="3" class="form-control">
                </div>
                <input v-model="paymentData.titular" placeholder="Nombre en la tarjeta" class="form-control mt-2">
             </div>
          </div>
        </div>

        <div class="final-summary">
          <h4>Resumen de Orden</h4>
          <div class="summary-list">
             <div v-for="(item, i) in cartItems" :key="i" class="summary-item">
                <span>{{ item.nombre || item.descripcion }} x{{ selectedTravelers.length }}</span>
                <span>${{ ((item.precio || item.costo) * selectedTravelers.length).toFixed(2) }}</span>
             </div>
          </div>
          <hr>
          <div class="total-big">
            <span>Total a Pagar Hoy:</span>
            <span>${{ isFinanced ? (cartTotal * 0.5).toFixed(2) : cartTotal.toFixed(2) }}</span>
          </div>
          <button class="btn-confirm" @click="processPayment" :disabled="processing">
            <i v-if="processing" class="fa-solid fa-spinner fa-spin"></i> 
            {{ processing ? 'Procesando...' : 'Confirmar Compra' }}
          </button>
        </div>
      </div>

      <div class="actions-footer">
        <button class="btn-back" @click="currentStep--">Atrás</button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();
const currentStep = ref(1);
const myTravelers = ref([]);
const selectedTravelers = ref([]); // Array de IDs
const loading = ref(false);

const availableProducts = ref([]);
const selectedProductType = ref('servicio');
const selectedProduct = ref(null);
const cartItems = ref([]);

const isFinanced = ref(false);
const paymentMethod = ref('zelle');
const paymentData = reactive({});
const processing = ref(false);

const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

// --- PASO 1: CARGAR VIAJEROS ---
const loadTravelers = async () => {
    loading.value = true;
    try {
        // Asegúrate que esta ruta coincida con la que definiste en tu backend para sp_obtener_viajeros_usuario
        const res = await fetch('http://localhost:3000/api/users/travelers/list', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) {
            myTravelers.value = data.data;
        } else {
            console.error("Error cargando viajeros:", data.message);
        }
    } catch(e) {
        console.error("Error de red:", e);
    } finally {
        loading.value = false;
    }
};

const toggleTraveler = (id) => {
    if (selectedTravelers.value.includes(id)) {
        selectedTravelers.value = selectedTravelers.value.filter(t => t !== id);
    } else {
        selectedTravelers.value.push(id);
    }
};

// --- PASO 2: CARGA DINÁMICA DE PRODUCTOS ---
watch(selectedProductType, async (val) => {
    selectedProduct.value = null; // Resetear selección
    availableProducts.value = [];
    
    let url = '';
    if(val === 'servicio') url = 'http://localhost:3000/api/opciones/servicios'; 
    // Nota: Para traslados, podrías reutilizar sp_listar_traslados_disponibles
    else if(val === 'traslado') url = 'http://localhost:3000/api/traslados-disponibles'; 
    else if(val === 'paquete') url = 'http://localhost:3000/api/paquetes';

    try {
        const res = await fetch(url);
        const data = await res.json();
        if(data.success) {
            // Normalizamos la data para que el select funcione (algunos traen nombre, otros descripcion, otros titulo)
            availableProducts.value = data.data.map(item => ({
                ...item,
                nombre: item.nombre || item.descripcion || item.paq_tur_nombre, // Fallback de nombres
                precio: item.costo || item.precio || item.paq_tur_monto_total // Fallback de precios
            }));
        }
    } catch(e) { console.error(e); }
});

const addItemToCart = () => {
    if(!selectedProduct.value) return;
    
    cartItems.value.push({
        ...selectedProduct.value,
        tipo: selectedProductType.value,
        es_paquete: selectedProductType.value === 'paquete'
    });
    selectedProduct.value = null;
};

const getIcon = (tipo) => {
    if(tipo === 'servicio') return 'fa-solid fa-ticket';
    if(tipo === 'traslado') return 'fa-solid fa-plane';
    if(tipo === 'paquete') return 'fa-solid fa-box-open';
    return 'fa-solid fa-star';
};

const cartTotal = computed(() => {
    // Precio del item * cantidad de viajeros seleccionados
    return cartItems.value.reduce((acc, item) => {
        const price = parseFloat(item.precio || item.costo || 0);
        return acc + (price * selectedTravelers.value.length);
    }, 0);
});

// --- PASO 3: PROCESAR PAGO ---
const processPayment = async () => {
    processing.value = true;
    
    // Preparar Items Simplificados para el SP (tipo, id)
    // El SP espera: [{"tipo":"servicio","id":1}, ...]
    const itemsPayload = cartItems.value.map(i => ({ 
        tipo: i.tipo, 
        // Ajuste de ID según el tipo de objeto que vino del backend
        id: i.id || i.ser_codigo || i.tras_codigo || i.paq_tur_codigo 
    }));

    const payload = {
        user_id: userSession.user_id,
        viajeros: selectedTravelers.value, // Array de IDs
        items: itemsPayload,
        pago: {
            metodo: paymentMethod.value,
            datos: paymentData,
            es_financiado: isFinanced.value
        }
    };

    try {
        const res = await fetch('http://localhost:3000/api/cart/checkout', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert('¡Compra Exitosa! Redirigiendo a tus servicios...');
            router.push('/client/dashboard'); 
        } else {
            alert('Error: ' + data.message); // Mensajes de reglas o fechas
        }
    } catch(e) {
        alert('Error de conexión con el servidor');
    } finally {
        processing.value = false;
    }
};

onMounted(() => {
    // Cargar viajeros apenas se monta el componente
    if(userSession.user_id) {
        loadTravelers();
        // Disparar carga inicial de servicios para que el select no esté vacío
        selectedProductType.value = 'servicio'; 
    } else {
        router.push('/login');
    }
});
</script>

<style scoped>
.cart-container {
  max-width: 900px;
  margin: 40px auto;
  font-family: 'Segoe UI', sans-serif;
  color: #333;
}

/* STEPPER */
.stepper-wrapper {
  display: flex;
  justify-content: space-between;
  margin-bottom: 40px;
  position: relative;
}
.stepper-wrapper::before {
  content: '';
  position: absolute;
  top: 15px;
  left: 0;
  width: 100%;
  height: 2px;
  background: #e0e0e0;
  z-index: 0;
}
.stepper-item {
  position: relative;
  z-index: 1;
  text-align: center;
  background: #fff; /* Tapar linea */
  padding: 0 10px;
}
.step-counter {
  width: 35px;
  height: 35px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid #ccc;
  color: #ccc;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin: 0 auto 5px;
  transition: all 0.3s;
}
.step-name {
  font-size: 0.85rem;
  color: #999;
  font-weight: 600;
}
/* Active / Completed States */
.stepper-item.active .step-counter { border-color: #3b82f6; color: #3b82f6; }
.stepper-item.active .step-name { color: #3b82f6; }
.stepper-item.completed .step-counter { background: #3b82f6; border-color: #3b82f6; color: white; }
.stepper-item.completed .step-name { color: #333; }

/* CONTENT BOX */
.step-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.05);
}
.fade-in { animation: fadeIn 0.4s ease-out; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

.section-header { margin-bottom: 25px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
.section-header h3 { margin: 0 0 5px 0; font-size: 1.5rem; color: #1e293b; }
.section-header p { margin: 0; color: #64748b; }

/* VIAJEROS GRID */
.travelers-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 15px;
  margin-bottom: 30px;
}
.traveler-card {
  border: 2px solid #f1f5f9;
  border-radius: 10px;
  padding: 15px;
  display: flex;
  align-items: center;
  gap: 15px;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
}
.traveler-card:hover { border-color: #cbd5e1; background: #f8fafc; }
.traveler-card.selected { border-color: #3b82f6; background: #eff6ff; }
.avatar {
  width: 45px;
  height: 45px;
  background: #e2e8f0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #64748b;
  font-size: 1.1rem;
}
.traveler-card.selected .avatar { background: #3b82f6; color: white; }
.info { display: flex; flex-direction: column; }
.info strong { font-size: 0.95rem; color: #334155; }
.info small { font-size: 0.75rem; color: #94a3b8; }
.check-indicator {
  position: absolute; top: 10px; right: 10px;
  color: #3b82f6; display: none;
}
.traveler-card.selected .check-indicator { display: block; }

/* FINDER (PASO 2) */
.product-finder { background: #f8fafc; padding: 20px; border-radius: 8px; margin-bottom: 25px; }
.finder-controls { display: flex; gap: 10px; }
.form-control {
  padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; outline: none;
}
.type-select { width: 30%; }
.product-select { flex: 1; }
.btn-add { background: #10b981; color: white; border: none; padding: 0 20px; border-radius: 6px; font-weight: 600; cursor: pointer; }
.btn-add:disabled { background: #ccc; cursor: not-allowed; }

/* CART LIST */
.cart-list { margin-bottom: 30px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; }
.cart-item {
  display: flex; align-items: center; padding: 15px 20px; border-bottom: 1px solid #f1f5f9; background: white;
}
.cart-item:last-child { border-bottom: none; }
.item-icon { width: 40px; font-size: 1.2rem; color: #64748b; text-align: center; }
.item-details { flex: 1; padding: 0 15px; }
.item-details h4 { margin: 0 0 5px 0; font-size: 1rem; }
.badge { background: #f1f5f9; color: #475569; padding: 2px 8px; border-radius: 4px; font-size: 0.75rem; text-transform: uppercase; font-weight: 700; }
.warning-text { color: #f59e0b; font-size: 0.8rem; margin-top: 4px; }
.item-quantity { text-align: center; padding: 0 20px; }
.qty-display { font-weight: 700; font-size: 1.1rem; }
.item-price { text-align: right; min-width: 100px; }
.total-price { font-weight: 700; color: #333; font-size: 1.1rem; }
.unit-price { font-size: 0.8rem; color: #94a3b8; }
.btn-delete {
  background: none; border: none; color: #ef4444; margin-left: 20px; cursor: pointer; font-size: 1rem; opacity: 0.6;
}
.btn-delete:hover { opacity: 1; }

.cart-summary-box { background: #f8fafc; padding: 20px; border-radius: 8px; text-align: right; }
.summary-row { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 0.95rem; color: #64748b; }
.summary-row.total { font-size: 1.3rem; font-weight: 800; color: #1e293b; border-top: 1px solid #e2e8f0; padding-top: 10px; margin-top: 10px; }

/* PAGO (PASO 3) */
.payment-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 30px; }
.radio-card {
  display: flex; align-items: center; border: 2px solid #f1f5f9; padding: 15px; border-radius: 8px; margin-bottom: 10px; cursor: pointer;
}
.radio-card.checked { border-color: #3b82f6; background: #eff6ff; }
.radio-card input { display: none; }
.radio-content { flex: 1; display: flex; flex-direction: column; }
.finance-breakdown { background: #fffbeb; border: 1px solid #fcd34d; padding: 15px; border-radius: 8px; font-size: 0.9rem; margin-top: 10px; }
.breakdown-row { display: flex; justify-content: space-between; margin-bottom: 5px; }

.final-summary { background: #f8fafc; padding: 20px; border-radius: 8px; height: fit-content; }
.summary-item { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.9rem; color: #475569; }
.total-big { display: flex; justify-content: space-between; font-size: 1.2rem; font-weight: 800; margin-top: 15px; }
.btn-confirm {
  width: 100%; background: #3b82f6; color: white; padding: 12px; border: none; border-radius: 6px; font-weight: 700; margin-top: 20px; cursor: pointer;
}
.btn-confirm:hover { background: #2563eb; }
.btn-confirm:disabled { background: #94a3b8; }

/* FOOTER */
.actions-footer { display: flex; justify-content: space-between; margin-top: 30px; }
.btn-next { background: #1e293b; color: white; padding: 10px 25px; border-radius: 6px; border: none; font-weight: 600; cursor: pointer; }
.btn-next:disabled { background: #e2e8f0; color: #94a3b8; cursor: not-allowed; }
.btn-back { background: transparent; border: 1px solid #cbd5e1; color: #475569; padding: 10px 25px; border-radius: 6px; cursor: pointer; }

/* Estados vacíos */
.empty-state, .empty-cart { text-align: center; padding: 40px; color: #94a3b8; }
.empty-state i { font-size: 3rem; margin-bottom: 15px; opacity: 0.5; }
.btn-link { background: none; border: none; color: #3b82f6; text-decoration: underline; cursor: pointer; }
</style>