/**
 * GymManager - JavaScript principal
 * Este archivo contiene las funciones principales para la aplicación
 */

// Esperar a que el DOM esté listo
document.addEventListener('DOMContentLoaded', function() {
    console.log('GymManager - Aplicación inicializada');
    
    // Inicializar componentes
    initializeTooltips();
    initializePopovers();
    setupFormValidation();
    setupAlertDismiss();
    
    // Verificar si estamos en la página correcta y ejecutar funciones específicas
    if (document.getElementById('dashboard-charts')) {
        initializeDashboardCharts();
    }
});

/**
 * Inicializa los tooltips de Bootstrap
 */
function initializeTooltips() {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

/**
 * Inicializa los popovers de Bootstrap
 */
function initializePopovers() {
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
}

/**
 * Configura la validación de formularios
 */
function setupFormValidation() {
    // Obtener todos los formularios a los que queremos aplicar estilos de validación de Bootstrap
    const forms = document.querySelectorAll('.needs-validation');

    // Loop sobre ellos y prevenir envío
    Array.from(forms).forEach(form => {
        form.addEventListener('submit', event => {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }

            form.classList.add('was-validated');
        }, false);
    });
}

/**
 * Configura el cierre automático de alertas después de un tiempo
 */
function setupAlertDismiss() {
    // Cerrar alertas automáticamente después de 5 segundos
    const alertList = document.querySelectorAll('.alert-auto-dismiss');
    alertList.forEach(function (alert) {
        setTimeout(function() {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
}

/**
 * Inicializa los gráficos del panel de control
 */
function initializeDashboardCharts() {
    console.log('Inicializando gráficos del panel de control');
    
    // Aquí iría el código para inicializar gráficos, 
    // usando bibliotecas como Chart.js o ApexCharts
    
    // Ejemplo: 
    // Si estuviéramos usando Chart.js, podríamos tener algo como:
    /*
    const ctx = document.getElementById('attendanceChart').getContext('2d');
    const attendanceChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'],
            datasets: [{
                label: 'Asistencia diaria',
                data: [12, 19, 15, 17, 14, 10, 8],
                borderColor: 'rgba(75, 192, 192, 1)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true
        }
    });
    */
}

/**
 * Función para mostrar un mensaje de confirmación antes de realizar una acción
 * @param {string} message - Mensaje a mostrar
 * @param {function} callback - Función a ejecutar si se confirma
 */
function confirmAction(message, callback) {
    if (confirm(message)) {
        callback();
    }
}

/**
 * Función para formatear fechas
 * @param {Date|string} date - Fecha a formatear
 * @param {string} format - Formato deseado (corto, largo, hora)
 * @returns {string} Fecha formateada
 */
function formatDate(date, format = 'corto') {
    const dateObj = date instanceof Date ? date : new Date(date);
    
    const options = {
        corto: { day: '2-digit', month: '2-digit', year: 'numeric' },
        largo: { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' },
        hora: { hour: '2-digit', minute: '2-digit' }
    };
    
    return dateObj.toLocaleDateString('es-ES', options[format] || options.corto);
}

/**
 * Función para cargar datos mediante AJAX
 * @param {string} url - URL para la solicitud
 * @param {function} successCallback - Función a ejecutar si la solicitud es exitosa
 * @param {function} errorCallback - Función a ejecutar si hay un error
 */
function loadData(url, successCallback, errorCallback) {
    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Error en la respuesta del servidor');
            }
            return response.json();
        })
        .then(data => {
            successCallback(data);
        })
        .catch(error => {
            console.error('Error al cargar datos:', error);
            if (errorCallback) {
                errorCallback(error);
            }
        });
}

/**
 * Muestra un mensaje de notificación
 * @param {string} message - Mensaje a mostrar
 * @param {string} type - Tipo de mensaje (success, error, warning, info)
 */
function showNotification(message, type = 'info') {
    // Crear elemento de notificación
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-message">${message}</span>
            <button class="notification-close">&times;</button>
        </div>
    `;
    
    // Añadir la notificación al contenedor o al body
    const container = document.getElementById('notification-container') || document.body;
    container.appendChild(notification);
    
    // Configurar botón de cierre
    const closeButton = notification.querySelector('.notification-close');
    closeButton.addEventListener('click', function() {
        notification.remove();
    });
    
    // Remover la notificación después de 5 segundos
    setTimeout(function() {
        notification.remove();
    }, 5000);
} 