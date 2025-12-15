import { createRouter, createWebHistory } from 'vue-router';

// Imports de componentes
// Asegúrate de usar '@/' para referenciar 'src/'
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';
import AdminDashboard from '@/views/admin/AdminDashboard.vue';
import ProviderAirlineDashboard from '@/views/provider/ProviderAirlineDashboard.vue';
import NotDevelopedYet from '@/views/general/NotDevelopedYet.vue';
import HomePage from '@/views/general/HomePage.vue';
import Cart from '@/views/client/Cart.vue';

// CORRECCIÓN AQUÍ: Agregada la barra '/' después de la arroba
import SearchResults from '@/views/general/SearchResults.vue';

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            name: 'home',
            component: HomePage
        },
        {
            path: '/login',
            name: 'login',
            component: Login
        },
        {
            path: '/client/register/',
            name: 'client-register',
            component: SelfRegisterClient
        },
        {
            path: '/client/dashboard',
            name: 'client-dashboard',
            component: ClientDashboard
        },
        {
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            component: AdminDashboard
        },
        {
            path: '/providers/airlines/dashboard',
            name: 'providers-airlines-dashboard',
            component: ProviderAirlineDashboard
        },
        {
            path: '/not-developed',
            name: 'NotDeveloped',
            component: NotDevelopedYet
        },
        { 
            path: '/results', 
            name: 'results', 
            component: SearchResults,
            // Esta función permite pasar los query params (?destino=x) como props al componente
            props: route => ({ query: route.query }) 
        },
        {
            path:'/cart',
            name:'cart',
            component:Cart
        }
    ]
})

export default router;