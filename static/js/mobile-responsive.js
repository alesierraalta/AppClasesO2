/**
 * Script para transformar la interfaz web en una experiencia de app iOS en dispositivos móviles
 */
document.addEventListener('DOMContentLoaded', function() {
    // Detectar si es un dispositivo móvil
    const isMobile = window.innerWidth <= 768;
    if (isMobile) {
        console.log('Transformando interfaz a estilo iOS');
        
        // Aplicar estructura general iOS
        applyIOSStructure();
        
        // Transformar cards a estilo iOS
        convertCardsToIOS();
        
        // Transformar tablas a estilo iOS
        convertTablesToIOS();
        
        // Transformar botones a estilo iOS
        convertButtonsToIOS();
        
        // Crear barra inferior de navegación iOS
        createIOSTabBar();
        
        // Crear cabecera estilo iOS
        createIOSHeader();
        
        // Mejorar la sección de informes para iOS
        enhanceIOSReports();
        
        // Aplicar animaciones y transiciones iOS
        applyIOSAnimations();
        
        // Agregar gestos iOS
        setupIOSGestures();
    }
    
    // Escuchar cambios en el tamaño de ventana
    window.addEventListener('resize', function() {
        const isMobileNow = window.innerWidth <= 768;
        if (isMobileNow) {
            // Replicar cambios si no se han aplicado ya
            if (!document.body.classList.contains('ios-style')) {
                applyIOSStructure();
                convertCardsToIOS();
                convertTablesToIOS();
                convertButtonsToIOS();
                createIOSTabBar();
                createIOSHeader();
                enhanceIOSReports();
                applyIOSAnimations();
                setupIOSGestures();
            }
        } else {
            // Revertir a la versión web si es necesario
            // (opcional, depende de los requisitos)
        }
    });

    /**
     * Funciones para transformar la interfaz
     */
    
    // Aplicar estructura general estilo iOS
    function applyIOSStructure() {
        // Evitar aplicar cambios duplicados
        if (document.body.classList.contains('ios-style')) return;
        
        // Marcar el cuerpo para evitar duplicados
        document.body.classList.add('ios-style');
        
        // Convertir container principal a contenedor iOS
        const mainContainer = document.querySelector('.container, .container-fluid');
        if (mainContainer) {
            mainContainer.classList.add('ios-container');
        }
        
        // Crear el fondo gris característico de iOS
        const backgroundLayer = document.createElement('div');
        backgroundLayer.className = 'ios-background-layer';
        document.body.insertBefore(backgroundLayer, document.body.firstChild);
        
        // Aplicar estilos a la estructura principal
        const contentWrappers = document.querySelectorAll('.content, main, [role="main"]');
        contentWrappers.forEach(wrapper => {
            wrapper.style.paddingTop = '10px';
            wrapper.style.paddingBottom = '10px';
        });
        
        // Agregar separadores entre secciones
        const mainSections = document.querySelectorAll('section, .card, .row');
        mainSections.forEach(section => {
            // Solo agregar separadores entre secciones principales
            if (section.parentElement && (section.parentElement.tagName === 'MAIN' || section.parentElement.tagName === 'BODY')) {
                const separator = document.createElement('div');
                separator.className = 'ios-separator';
                section.parentNode.insertBefore(separator, section.nextSibling);
            }
        });
        
        // Convertir títulos de sección
        const sectionTitles = document.querySelectorAll('h1, h2, h3');
        sectionTitles.forEach(title => {
            if (!title.closest('.card-header, .ios-header')) {
                title.classList.add('ios-section-title');
            }
        });
    }
    
    // Transformar cards a estilo iOS
    function convertCardsToIOS() {
        // Convertir todas las cards Bootstrap a estilo iOS
        const cards = document.querySelectorAll('.card');
        cards.forEach(card => {
            card.classList.add('ios-card');
            
            // Aplicar estilo iOS a las partes de la card
            const cardHeader = card.querySelector('.card-header');
            if (cardHeader) {
                cardHeader.classList.add('ios-card-header');
            }
            
            const cardBody = card.querySelector('.card-body');
            if (cardBody) {
                cardBody.classList.add('ios-card-body');
            }
            
            const cardFooter = card.querySelector('.card-footer');
            if (cardFooter) {
                cardFooter.classList.add('ios-card-footer');
            }
        });
        
        // Convertir cards de resumen
        const summaryCards = document.querySelectorAll('#resumen .card');
        summaryCards.forEach(card => {
            card.classList.add('ios-summary-card');
            
            // Ajustar estructura interna de tarjetas de resumen
            const cardTitle = card.querySelector('.card-title');
            const cardValue = card.querySelector('.card-text');
            
            if (cardTitle && cardValue) {
                cardValue.classList.add('ios-summary-value');
                cardTitle.classList.add('ios-summary-label');
                
                // Reorganizar para que el valor aparezca primero (estilo iOS)
                const cardBody = card.querySelector('.card-body');
                if (cardBody) {
                    cardBody.innerHTML = '';
                    cardBody.appendChild(cardValue);
                    cardBody.appendChild(cardTitle);
                }
            }
        });
    }
    
    // Transformar tablas a estilo iOS
    function convertTablesToIOS() {
        // Asegurar que todas las tablas estén en contenedores responsive
        const tables = document.querySelectorAll('table');
        tables.forEach(table => {
            // Estilo iOS para todas las tablas
            table.classList.add('ios-table-content');
            
            // Asegurar que están en un contenedor adecuado
            let tableResponsiveParent = table.closest('.table-responsive');
            if (!tableResponsiveParent) {
                // Crear wrapper iOS para tabla
                const wrapper = document.createElement('div');
                wrapper.className = 'ios-table table-responsive';
                
                // Envolver la tabla
                table.parentNode.insertBefore(wrapper, table);
                wrapper.appendChild(table);
                tableResponsiveParent = wrapper;
            } else {
                // Si ya tiene un contenedor responsive, agregar clase iOS
                tableResponsiveParent.classList.add('ios-table');
            }
            
            // Agregar indicador de scroll horizontal en estilo iOS
            if (!tableResponsiveParent.querySelector('.ios-scroll-indicator')) {
                const scrollIndicator = document.createElement('div');
                scrollIndicator.className = 'ios-scroll-indicator';
                scrollIndicator.innerHTML = '<i class="fas fa-arrows-left-right"></i>';
                
                tableResponsiveParent.appendChild(scrollIndicator);
                
                // Ocultar/mostrar el indicador según el scroll
                tableResponsiveParent.addEventListener('scroll', function() {
                    scrollIndicator.style.opacity = '0';
                    
                    // Mostrar nuevamente después de un tiempo
                    clearTimeout(this.scrollTimer);
                    this.scrollTimer = setTimeout(() => {
                        if (this.scrollWidth > this.clientWidth) {
                            scrollIndicator.style.opacity = '0.7';
                        }
                    }, 500);
                });
            }
        });
        
        // Convertir tablas específicas
        const reportTables = document.querySelectorAll('#tablaResumenProfesores, #tableclases, #tablaNoRegistradas');
        reportTables.forEach(table => {
            table.classList.add('ios-compact-table');
        });
    }
    
    // Transformar botones a estilo iOS
    function convertButtonsToIOS() {
        // Estilo iOS para todos los botones
        const buttons = document.querySelectorAll('.btn');
        buttons.forEach(button => {
            button.classList.add('ios-button');
            
            // Mantener iconos pero ajustar su posición
            const icon = button.querySelector('i, .fas, .far, .fa, .bi');
            if (icon) {
                // Espaciado adecuado entre icono y texto
                icon.style.marginRight = '6px';
            }
            
            // Botones de exportación o acción especial
            if (button.classList.contains('btn-export') || 
                button.classList.contains('btn-download') || 
                button.getAttribute('data-action') === 'export') {
                button.classList.add('ios-button-outline');
            }
            
            // Mejorar contraste en botones pequeños
            if (button.classList.contains('btn-sm')) {
                button.classList.add('ios-button-sm');
            }
        });
        
        // Crear botón de acción flotante (estilo iOS)
        const actionButtonsContainer = document.querySelector('.btn-toolbar');
        if (actionButtonsContainer && !document.querySelector('.ios-action-circle')) {
            // Buscar un botón principal para usar como base del FAB
            const primaryBtn = actionButtonsContainer.querySelector('.btn-primary, .btn-success, button[type="submit"]');
            if (primaryBtn) {
                const actionCircle = document.createElement('div');
                actionCircle.className = 'ios-action-circle';
                
                // Usar el icono del botón o un icono predeterminado
                const icon = primaryBtn.querySelector('i') ? 
                             primaryBtn.querySelector('i').cloneNode(true) : 
                             document.createElement('i');
                
                if (!primaryBtn.querySelector('i')) {
                    icon.className = 'fas fa-plus';
                }
                
                actionCircle.appendChild(icon);
                actionCircle.title = primaryBtn.textContent.trim();
                
                // Agregar funcionalidad al botón
                actionCircle.addEventListener('click', function() {
                    primaryBtn.click();
                });
                
                document.body.appendChild(actionCircle);
            }
        }
    }
    
    // Crear barra inferior de navegación estilo iOS
    function createIOSTabBar() {
        // Evitar duplicados
        if (document.querySelector('.ios-tab-bar')) return;
        
        const tabBar = document.createElement('div');
        tabBar.className = 'ios-tab-bar';
        
        // Determinar qué pestañas mostrar basado en la sección actual
        const currentPath = window.location.pathname;
        
        // Estructura básica de tabs 
        const tabs = [
            { icon: 'fas fa-home', label: 'Inicio', url: '/', active: currentPath === '/' || currentPath === '/index.html' },
            { icon: 'fas fa-calendar', label: 'Clases', url: '/clases', active: currentPath.includes('/clase') },
            { icon: 'fas fa-chart-bar', label: 'Informes', url: '/informes', active: currentPath.includes('/informe') },
            { icon: 'fas fa-user', label: 'Perfil', url: '/perfil', active: currentPath.includes('/perfil') }
        ];
        
        // Crear cada tab
        tabs.forEach(tab => {
            const tabItem = document.createElement('a');
            tabItem.className = `ios-tab-item ${tab.active ? 'active' : ''}`;
            tabItem.href = tab.url;
            
            const tabIcon = document.createElement('div');
            tabIcon.className = 'ios-tab-icon';
            tabIcon.innerHTML = `<i class="${tab.icon}"></i>`;
            
            const tabLabel = document.createElement('div');
            tabLabel.className = 'ios-tab-label';
            tabLabel.textContent = tab.label;
            
            tabItem.appendChild(tabIcon);
            tabItem.appendChild(tabLabel);
            tabBar.appendChild(tabItem);
        });
        
        document.body.appendChild(tabBar);
    }
    
    // Crear cabecera estilo iOS
    function createIOSHeader() {
        // Evitar duplicados
        if (document.querySelector('.ios-header')) return;
        
        const header = document.createElement('div');
        header.className = 'ios-header';
        
        // Determinar el título basado en el contenido de la página
        let title = document.title.split(' | ')[0]; // Intentar extraer el título principal
        
        // Si hay un h1 o h2 en la página, usar ese texto
        const mainHeading = document.querySelector('h1, h2');
        if (mainHeading) {
            title = mainHeading.textContent.trim();
        }
        
        // Estructura para la cabecera
        let headerHTML = `<div class="ios-header-title">${title}</div>`;
        
        // Si no estamos en la página de inicio, agregar botón atrás
        if (window.location.pathname !== '/' && window.location.pathname !== '/index.html') {
            headerHTML = `
                <a href="javascript:history.back()" class="ios-back-button">
                    <i class="fas fa-chevron-left"></i> Atrás
                </a>
                ${headerHTML}
            `;
        }
        
        // Si hay botones de acción relevantes, agregar uno a la cabecera
        const actionButton = document.querySelector('.btn-primary, .btn-success');
        if (actionButton && !actionButton.closest('form') && !actionButton.classList.contains('toggle-clases')) {
            const actionIcon = actionButton.querySelector('i');
            const iconClass = actionIcon ? actionIcon.className : 'fas fa-plus';
            
            headerHTML += `
                <a href="#" class="ios-action-button" id="header-action-button">
                    <i class="${iconClass}"></i>
                </a>
            `;
        }
        
        header.innerHTML = headerHTML;
        document.body.insertBefore(header, document.body.firstChild);
        
        // Agregar funcionalidad al botón de acción en el header
        const headerActionButton = document.getElementById('header-action-button');
        if (headerActionButton && actionButton) {
            headerActionButton.addEventListener('click', function(e) {
                e.preventDefault();
                actionButton.click();
            });
        }
    }
    
    // Mejorar la sección de informes para iOS
    function enhanceIOSReports() {
        // Verificar si estamos en la página de informes
        const isReportPage = window.location.pathname.includes('/informe') || 
                            document.querySelector('h1, h2')?.textContent.includes('Informe');
        
        if (isReportPage) {
            console.log('Aplicando mejoras iOS a la sección de informes');
            
            // Convertir tablas de informes a vista estilo iOS
            const reportTables = {
                resumen: document.getElementById('tablaResumenProfesores'),
                clases: document.getElementById('tableclases'),
                noRegistradas: document.getElementById('tablaNoRegistradas')
            };
            
            // Transformar tabla de profesores a lista de iOS
            if (reportTables.resumen) {
                createIOSTeacherList(reportTables.resumen);
            }
            
            // Convertir tarjetas de resumen a estilo iOS
            const resumenCards = document.querySelectorAll('#resumen .card');
            if (resumenCards.length > 0) {
                const iosGrid = document.createElement('div');
                iosGrid.className = 'ios-grid';
                
                // Insertar grid después del título
                const parentContainer = resumenCards[0].parentElement.parentElement;
                parentContainer.insertBefore(iosGrid, resumenCards[0].parentElement);
                
                // Mover las tarjetas al grid
                resumenCards.forEach(card => {
                    const iosCard = document.createElement('div');
                    iosCard.className = 'ios-summary-card';
                    
                    // Extraer valor y etiqueta
                    const value = card.querySelector('.card-text')?.textContent;
                    const label = card.querySelector('.card-title')?.textContent;
                    
                    if (value && label) {
                        iosCard.innerHTML = `
                            <div class="ios-summary-value">${value}</div>
                            <div class="ios-summary-label">${label}</div>
                        `;
                        
                        iosGrid.appendChild(iosCard);
                    }
                });
                
                // Ocultar las tarjetas originales
                resumenCards.forEach(card => {
                    card.parentElement.style.display = 'none';
                });
            }
            
            // Crear barra de filtros iOS para informes
            createIOSFilterBar();
        }
    }
    
    // Crear lista estilo iOS para profesores
    function createIOSTeacherList(teacherTable) {
        if (!teacherTable) return;
        
        // Evitar procesamiento duplicado
        if (teacherTable.getAttribute('data-ios-processed')) return;
        teacherTable.setAttribute('data-ios-processed', 'true');
        
        // Crear contenedor para la lista iOS
        const iosList = document.createElement('div');
        iosList.className = 'ios-list ios-teacher-list';
        iosList.id = 'ios-teacher-list';
        
        // Procesar cada fila de la tabla
        const rows = teacherTable.querySelectorAll('tbody tr:not(.clases-detalle)');
        rows.forEach(row => {
            // Extraer datos del profesor
            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;
            
            // Extraer la información del profesor
            const nameCell = cells[0];
            const totalClasesCell = cells.length > 2 ? cells[2] : null;
            const totalHorasCell = cells.length > 3 ? cells[3] : null;
            const detailsButton = row.querySelector('.toggle-clases');
            
            // Crear elemento de lista iOS
            const teacherItem = document.createElement('div');
            teacherItem.className = 'ios-teacher-row';
            
            // Avatar con iniciales o imagen
            let avatarContent = '';
            const imgElement = nameCell.querySelector('img');
            
            if (imgElement) {
                // Si hay imagen, usarla
                avatarContent = imgElement.outerHTML;
            } else {
                // Si no hay imagen, crear avatar con iniciales
                const nameText = nameCell.textContent.trim();
                const initials = nameText.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
                avatarContent = `<div class="ios-teacher-avatar">${initials}</div>`;
            }
            
            // Extraer datos adicionales
            const name = nameCell.textContent.trim();
            const totalClases = totalClasesCell ? totalClasesCell.textContent.trim() : '';
            const totalHoras = totalHorasCell ? totalHorasCell.textContent.trim() : '';
            
            // Construir el elemento de lista
            teacherItem.innerHTML = `
                ${avatarContent}
                <div class="ios-teacher-info">
                    <div class="ios-teacher-name">${name}</div>
                    <div class="ios-teacher-details">
                        ${totalClases ? `Clases: ${totalClases}` : ''}
                        ${totalHoras ? ` • Horas: ${totalHoras}` : ''}
                    </div>
                </div>
                <div class="ios-teacher-actions">
                    <a href="#" class="ios-action-button ios-view-details">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </div>
            `;
            
            // Preservar la funcionalidad original del botón de detalles
            if (detailsButton) {
                const viewDetails = teacherItem.querySelector('.ios-view-details');
                if (viewDetails) {
                    viewDetails.addEventListener('click', function(e) {
                        e.preventDefault();
                        detailsButton.click();
                    });
                }
                
                // También hacer clickeable toda la fila
                teacherItem.addEventListener('click', function(e) {
                    if (!e.target.closest('.ios-action-button')) {
                        detailsButton.click();
                    }
                });
            }
            
            iosList.appendChild(teacherItem);
        });
        
        // Insertar la lista iOS antes de la tabla original
        const tableContainer = teacherTable.closest('.table-responsive');
        if (tableContainer) {
            tableContainer.parentNode.insertBefore(iosList, tableContainer);
            
            // Ocultar la tabla original (mantenemos para preservar funcionalidad)
            tableContainer.style.display = 'none';
            
            // Agregar botón para alternar entre vista iOS y tabla
            const toggleViewBtn = document.createElement('div');
            toggleViewBtn.className = 'ios-segmented';
            toggleViewBtn.innerHTML = `
                <div class="ios-segment active" data-view="ios">Lista</div>
                <div class="ios-segment" data-view="table">Tabla</div>
            `;
            
            // Insertar antes de la lista
            tableContainer.parentNode.insertBefore(toggleViewBtn, iosList);
            
            // Agregar funcionalidad para cambiar vistas
            const segments = toggleViewBtn.querySelectorAll('.ios-segment');
            segments.forEach(segment => {
                segment.addEventListener('click', function() {
                    const view = this.getAttribute('data-view');
                    segments.forEach(s => s.classList.remove('active'));
                    this.classList.add('active');
                    
                    if (view === 'ios') {
                        iosList.style.display = 'block';
                        tableContainer.style.display = 'none';
                    } else {
                        iosList.style.display = 'none';
                        tableContainer.style.display = 'block';
                    }
                });
            });
        }
    }
    
    // Crear barra de filtros estilo iOS
    function createIOSFilterBar() {
        // Buscar formularios de filtro
        const filterForm = document.querySelector('form.filter-form, form:has(select[name="mes"]), #seleccion-mes');
        
        if (filterForm && !document.querySelector('.ios-filter-bar')) {
            // Obtener los elementos de filtro (selects principalmente)
            const selects = filterForm.querySelectorAll('select');
            
            if (selects.length > 0) {
                // Crear barra de filtros
                const filterBar = document.createElement('div');
                filterBar.className = 'ios-filter-bar';
                
                // Para cada select, extraer sus opciones
                selects.forEach(select => {
                    const options = select.querySelectorAll('option');
                    const selectLabel = filterForm.querySelector(`label[for="${select.id}"]`)?.textContent || '';
                    const currentValue = select.value;
                    
                    // Crear botones de filtro para cada opción
                    options.forEach(option => {
                        if (!option.value) return; // Saltear opciones vacías
                        
                        const filterBtn = document.createElement('div');
                        filterBtn.className = `ios-filter-button ${option.value === currentValue ? 'active' : ''}`;
                        filterBtn.setAttribute('data-value', option.value);
                        filterBtn.setAttribute('data-select-id', select.id);
                        filterBtn.textContent = option.textContent;
                        
                        // Al click, actualizar el select original y enviar el form
                        filterBtn.addEventListener('click', function() {
                            const selectId = this.getAttribute('data-select-id');
                            const value = this.getAttribute('data-value');
                            const originalSelect = document.getElementById(selectId);
                            
                            if (originalSelect) {
                                originalSelect.value = value;
                                
                                // Actualizar UI
                                const allBtns = filterBar.querySelectorAll(`.ios-filter-button[data-select-id="${selectId}"]`);
                                allBtns.forEach(btn => btn.classList.remove('active'));
                                this.classList.add('active');
                                
                                // Enviar el formulario si existe un botón submit
                                const submitBtn = filterForm.querySelector('button[type="submit"], input[type="submit"]');
                                if (submitBtn) {
                                    submitBtn.click();
                                }
                            }
                        });
                        
                        filterBar.appendChild(filterBtn);
                    });
                });
                
                // Insertar la barra de filtros antes del formulario
                filterForm.parentNode.insertBefore(filterBar, filterForm);
                
                // Ocultar el formulario original pero mantenerlo para funcionalidad
                filterForm.style.display = 'none';
            }
        }
    }
    
    // Aplicar animaciones y transiciones estilo iOS
    function applyIOSAnimations() {
        // Agregar reglas CSS para animaciones
        const styleElement = document.createElement('style');
        styleElement.textContent = `
            .ios-fade-in {
                animation: ios-fade-in 0.3s ease forwards;
            }
            
            @keyframes ios-fade-in {
                0% { opacity: 0; transform: translateY(10px); }
                100% { opacity: 1; transform: translateY(0); }
            }
            
            .ios-button:active {
                transform: scale(0.97);
                opacity: 0.9;
            }
            
            .ios-card {
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            
            .ios-card:active {
                transform: scale(0.98);
            }
            
            .ios-tab-item {
                transition: color 0.2s ease;
            }
            
            .ios-list-item:active, .ios-teacher-row:active {
                background-color: #F2F2F7;
            }
        `;
        
        document.head.appendChild(styleElement);
        
        // Agregar clases de animación a elementos principales
        const animatedElements = document.querySelectorAll('.card, .ios-list, .ios-filter-bar, .ios-grid');
        animatedElements.forEach(el => {
            el.classList.add('ios-fade-in');
        });
    }
    
    // Agregar gestos tipo iOS (swipe, etc.)
    function setupIOSGestures() {
        // Implementar gestos solo si está disponible Hammer.js o similar
        if (typeof Hammer !== 'undefined') {
            // Implementar swipe para listas
            const lists = document.querySelectorAll('.ios-list-item, .ios-teacher-row');
            lists.forEach(item => {
                const hammer = new Hammer(item);
                hammer.on('swipeleft', function() {
                    // Mostrar acciones rápidas al deslizar
                    showIOSSwipeActions(item);
                });
            });
        } else {
            // Alternativa básica sin Hammer.js
            // Usando eventos touch nativos para detectar swipes
            const touchItems = document.querySelectorAll('.ios-list-item, .ios-teacher-row');
            touchItems.forEach(item => {
                let startX, startY;
                
                item.addEventListener('touchstart', function(e) {
                    startX = e.touches[0].clientX;
                    startY = e.touches[0].clientY;
                });
                
                item.addEventListener('touchend', function(e) {
                    if (!startX || !startY) return;
                    
                    const endX = e.changedTouches[0].clientX;
                    const endY = e.changedTouches[0].clientY;
                    
                    const diffX = startX - endX;
                    const diffY = startY - endY;
                    
                    // Si el movimiento horizontal es mayor que el vertical y es significativo
                    if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
                        if (diffX > 0) {
                            // Swipe izquierda
                            setupSimpleSwipeAction(item);
                        }
                    }
                });
            });
        }
    }
    
    // Mostrar acciones al deslizar (versión simple)
    function setupSimpleSwipeAction(item) {
        // Limpiar acciones existentes
        const existingActions = item.querySelector('.ios-swipe-actions');
        if (existingActions) {
            existingActions.remove();
            return;
        }
        
        // Crear acciones
        const actions = document.createElement('div');
        actions.className = 'ios-swipe-actions';
        actions.innerHTML = `
            <button class="ios-swipe-action ios-swipe-action-delete">
                <i class="fas fa-trash"></i>
            </button>
        `;
        
        item.style.position = 'relative';
        item.appendChild(actions);
        
        // Estilo para acciones
        actions.style.position = 'absolute';
        actions.style.right = '0';
        actions.style.top = '0';
        actions.style.bottom = '0';
        actions.style.display = 'flex';
        actions.style.alignItems = 'center';
        
        // Estilo para botón
        const deleteBtn = actions.querySelector('.ios-swipe-action-delete');
        deleteBtn.style.backgroundColor = '#FF3B30';
        deleteBtn.style.color = 'white';
        deleteBtn.style.border = 'none';
        deleteBtn.style.borderRadius = '8px';
        deleteBtn.style.padding = '10px 20px';
        deleteBtn.style.marginRight = '10px';
        
        // Ocultar al hacer click en cualquier lugar
        document.addEventListener('click', function hideActions() {
            actions.remove();
            document.removeEventListener('click', hideActions);
        });
    }
}); 