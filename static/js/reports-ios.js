/**
 * Mejoras específicas para la sección de reportes en iOS
 * Este archivo transforma las tablas de reportes en un formato optimizado para móviles
 */
document.addEventListener('DOMContentLoaded', function() {
    // Solo aplicar en dispositivos móviles y cuando estamos en la página de informes
    const isMobile = window.innerWidth <= 768;
    const isReportPage = window.location.pathname.includes('/informe') || 
                          document.title.includes('Informe') ||
                          document.querySelector('h1, h2')?.textContent.includes('Informe');
    
    if (isMobile && isReportPage) {
        console.log('Aplicando mejoras específicas para reportes en iOS');
        
        // Agregar clase general iOS al body si no existe ya
        if (!document.body.classList.contains('ios-style')) {
            document.body.classList.add('ios-style');
        }
        
        try {
            // Mostrar loading antes de cualquier transformación
            showLoadingIndicator();
            
            // Aplicar espaciado y organización optimizada - con prioridad alta
            improveReportLayout();
            
            // Ejecutar transformaciones asíncronas para mejorar rendimiento
            setTimeout(() => {
                // Transformar tablas de datos en vista de tarjetas
                transformReportTables();
                
                // Mejorar visualización de filtros
                enhanceReportFilters();
                
                // Organizar botones de exportación
                organizeExportButtons();
                
                // Mejorar visualización de gráficos
                enhanceCharts();
                
                // Agregar estados vacíos para elementos sin datos
                addEmptyStates();
                
                // Optimizar números y datos numéricos
                optimizeNumberDisplay();
                
                // Añadir indicador de desplazamiento horizontal para tablas
                addScrollIndicators();
                
                // Agregar navegación rápida (botón volver arriba)
                enhanceNavigation();
                
                // Ocultar loading después de todas las transformaciones
                setTimeout(hideLoadingIndicator, 300);
            }, 100);
        } catch (error) {
            console.error('Error al aplicar mejoras iOS:', error);
            // Ocultar el indicador de carga en caso de error
            hideLoadingIndicator();
        }
    }
    
    /**
     * Muestra un indicador de carga mientras se aplican las transformaciones
     */
    function showLoadingIndicator() {
        const loadingIndicator = document.createElement('div');
        loadingIndicator.className = 'ios-loading';
        loadingIndicator.id = 'ios-reports-loading';
        loadingIndicator.innerHTML = `
            <div class="ios-loading-spinner"></div>
            <div>Optimizando visualización...</div>
        `;
        
        // Insertar después del título principal si existe, o al inicio del contenido
        const mainTitle = document.querySelector('h1, h2');
        if (mainTitle && mainTitle.parentNode) {
            mainTitle.parentNode.insertBefore(loadingIndicator, mainTitle.nextSibling);
        } else {
            const mainContent = document.querySelector('main, .container, .container-fluid');
            if (mainContent) {
                mainContent.insertBefore(loadingIndicator, mainContent.firstChild);
            }
        }
    }
    
    /**
     * Oculta el indicador de carga
     */
    function hideLoadingIndicator() {
        const loadingIndicator = document.getElementById('ios-reports-loading');
        if (loadingIndicator) {
            loadingIndicator.style.opacity = '0';
            setTimeout(() => {
                loadingIndicator.remove();
            }, 300);
        }
    }
    
    /**
     * Mejora el espaciado y organización general de la página de reportes
     */
    function improveReportLayout() {
        // Agregar clase para identificar como sección de informes
        const mainContainer = document.querySelector('.container, .container-fluid');
        if (mainContainer) {
            mainContainer.classList.add('report-container');
        }
        
        // Envolver secciones principales en contenedores con mejor espaciado
        const reportSections = document.querySelectorAll('section, .row:has(table), .card:has(table)');
        reportSections.forEach(section => {
            if (!section.closest('.report-section') && !section.classList.contains('report-section')) {
                section.classList.add('report-section');
            }
        });
        
        // Mejorar títulos de sección
        const sectionTitles = document.querySelectorAll('h1, h2, h3, h4');
        sectionTitles.forEach(title => {
            if (!title.closest('.ios-header, .card-header')) {
                title.classList.add('report-title');
                
                // Añadir animación de entrada sutil
                title.style.opacity = '0';
                title.style.transform = 'translateY(10px)';
                
                setTimeout(() => {
                    title.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
                    title.style.opacity = '1';
                    title.style.transform = 'translateY(0)';
                }, 100);
            }
        });
        
        // Asegurar que los contenedores no estén demasiado apretados
        document.querySelectorAll('.card-body').forEach(body => {
            body.style.padding = '18px';
        });
        
        try {
            // Optimizar el espaciado de las cards del resumen
            convertSummaryCardsToIOSGrid();
            
            // Mejorar menú de navegación en pestañas si existe
            enhanceNavTabs();
        } catch (error) {
            console.warn('Error al mejorar layout:', error);
        }
    }
    
    /**
     * Convierte las tarjetas de resumen a una grilla estilo iOS
     */
    function convertSummaryCardsToIOSGrid() {
        // Buscar cards de resumen
        const summaryCards = document.querySelectorAll('#resumen .card, .summary-cards .card, .card.summary-card');
        
        if (summaryCards.length > 0) {
            // Crear grid estilo iOS
            const iosGrid = document.createElement('div');
            iosGrid.className = 'ios-stats-grid';
            
            // Insertar después del título del contenedor
            const container = summaryCards[0].closest('.row, section, .container');
            
            if (!container) {
                console.warn('No se encontró un contenedor para las tarjetas de resumen');
                return;
            }
            
            // Crear tarjetas estilo iOS y agregarlas al grid
            summaryCards.forEach((card, index) => {
                // Obtener valor y título
                const valueElement = card.querySelector('.card-text, .value, h3');
                const titleElement = card.querySelector('.card-title, .title, h4, small');
                
                if (valueElement && titleElement) {
                    const value = valueElement.textContent.trim();
                    const title = titleElement.textContent.trim();
                    
                    // Crear tarjeta estilo iOS
                    const iosCard = document.createElement('div');
                    iosCard.className = 'ios-stat-card';
                    iosCard.style.animationDelay = `${index * 0.1}s`;
                    
                    iosCard.innerHTML = `
                        <div class="ios-stat-value">${value}</div>
                        <div class="ios-stat-label">${title}</div>
                    `;
                    
                    iosGrid.appendChild(iosCard);
                    
                    // Ocultar tarjeta original
                    card.style.display = 'none';
                }
            });
            
            // Insertar el grid al inicio del contenedor
            try {
                const summaryContainer = document.querySelector('#resumen .row, .summary-cards');
                if (summaryContainer) {
                    summaryContainer.innerHTML = ''; // Limpiar contenedor original
                    summaryContainer.appendChild(iosGrid);
                } else {
                    container.prepend(iosGrid);
                }
            } catch (error) {
                container.prepend(iosGrid);
            }
        }
    }
    
    /**
     * Mejora el menú de navegación en pestañas
     */
    function enhanceNavTabs() {
        const navPills = document.querySelector('.report-nav-pills, .nav-pills, .nav-tabs');
        if (navPills) {
            // Asegurar scroll suave en la navegación por pestañas
            navPills.style.overflowX = 'auto';
            navPills.style.whiteSpace = 'nowrap';
            navPills.style.scrollbarWidth = 'none';
            navPills.style.webkitOverflowScrolling = 'touch';
            
            // Asegurar que los elementos de navegación tengan suficiente espacio táctil
            const navItems = navPills.querySelectorAll('.nav-item');
            navItems.forEach(item => {
                const link = item.querySelector('.nav-link');
                if (link) {
                    // Hacer los botones más grandes para mejor toque
                    link.style.minHeight = '44px';
                    link.style.display = 'flex';
                    link.style.alignItems = 'center';
                    
                    // Agregar efecto de toque
                    addTapEffect(link);
                    
                    // Manejar scroll automático al tab seleccionado
                    link.addEventListener('click', function() {
                        // Dar tiempo a que se aplique la clase 'active'
                        setTimeout(() => {
                            const activeLink = navPills.querySelector('.nav-link.active');
                            if (activeLink) {
                                activeLink.scrollIntoView({
                                    behavior: 'smooth',
                                    block: 'nearest',
                                    inline: 'center'
                                });
                            }
                        }, 100);
                    });
                }
            });
        }
    }
    
    /**
     * Transforma tablas de reportes en formato de tarjetas
     */
    function transformReportTables() {
        // Identificar tablas principales de reportes
        const reportTables = document.querySelectorAll('table:not(.no-transform)');
        
        reportTables.forEach((table, tableIndex) => {
            try {
                // Evitar transformaciones duplicadas
                if (table.hasAttribute('data-ios-transformed')) return;
                table.setAttribute('data-ios-transformed', 'true');
                
                // Verificar si la tabla tiene suficientes columnas para ser transformada
                const headerCells = table.querySelectorAll('thead th');
                if (headerCells.length < 2) return;
                
                // Agregar encabezado descriptivo para la tabla
                let tableTitle = '';
                
                // Buscar el título de la tabla
                const closestHeading = findClosestHeading(table);
                if (closestHeading) {
                    tableTitle = closestHeading.textContent.trim();
                } else {
                    // Si no hay título cercano, intentar usar el caption o generar uno
                    const caption = table.querySelector('caption');
                    tableTitle = caption ? caption.textContent.trim() : `Datos #${tableIndex + 1}`;
                }
                
                // Crear contenedor de tarjetas con un encabezado descriptivo
                const tableHeader = document.createElement('div');
                tableHeader.className = 'ios-table-header';
                tableHeader.innerHTML = `
                    <div class="ios-table-title">${tableTitle}</div>
                    <div class="ios-table-actions"></div>
                `;
                
                // Crear contenedor de tarjetas
                const cardsContainer = document.createElement('div');
                cardsContainer.className = 'ios-cards-view';
                
                // Obtener nombres de encabezados
                const headerTexts = Array.from(headerCells).map(th => th.textContent.trim());
                
                // Procesar filas de datos para crear tarjetas
                const dataRows = table.querySelectorAll('tbody tr:not(.clases-detalle)');
                
                if (dataRows.length === 0) {
                    // Si no hay datos, agregar estado vacío
                    cardsContainer.innerHTML = `
                        <div class="ios-empty-state">
                            <div class="ios-empty-state-icon">
                                <i class="fas fa-table"></i>
                            </div>
                            <div class="ios-empty-state-title">No hay datos disponibles</div>
                            <div class="ios-empty-state-text">No se encontraron registros para mostrar</div>
                        </div>
                    `;
                } else {
                    // Crear tarjetas para cada fila
                    dataRows.forEach((row, index) => {
                        // Crear tarjeta para esta fila
                        const card = document.createElement('div');
                        card.className = 'ios-report-card';
                        card.style.animationDelay = `${index * 0.05}s`;
                        card.classList.add('ios-fade-in');
                        
                        // Determinar si es una fila con un tipo especial (clase-move, clase-ride, etc.)
                        const rowClasses = Array.from(row.classList);
                        const specialClass = rowClasses.find(cls => cls.startsWith('clase-'));
                        if (specialClass) {
                            card.classList.add(specialClass + '-card');
                        }
                        
                        // Recolectar datos de celdas
                        const cells = row.querySelectorAll('td');
                        let cardContent = '';
                        
                        // Separar la primera celda como título de la tarjeta
                        const primaryCell = cells[0];
                        const primaryContent = primaryCell ? primaryCell.innerHTML : '';
                        
                        // Contenido principal (normalmente nombre o identificador)
                        cardContent += `
                            <div class="ios-card-main-content">
                                ${primaryContent}
                            </div>
                        `;
                        
                        // Información adicional en formato de lista
                        cardContent += '<div class="ios-card-details">';
                        
                        // Agregar resto de celdas como detalles
                        for (let i = 1; i < cells.length; i++) {
                            if (i < headerTexts.length && cells[i]) {
                                const label = headerTexts[i];
                                const value = cells[i].innerHTML;
                                const cellText = cells[i].textContent.trim();
                                
                                // Omitir celdas vacías o que contienen solo espacios
                                if (cellText === '') continue;
                                
                                // Omitir celdas que contienen solo botones si son la última columna
                                if (i === cells.length - 1 && cells[i].querySelector('button, .btn')) {
                                    cardContent += `<div class="ios-card-actions">${value}</div>`;
                                    continue;
                                }
                                
                                // Determinar si el contenido es numérico
                                const isNumeric = !isNaN(parseFloat(cellText)) && isFinite(cellText);
                                const dataType = isNumeric ? 'numeric' : '';
                                
                                // Determinar si es una cantidad monetaria
                                const isCurrency = cellText.includes('$') || cellText.startsWith('€') || label.toLowerCase().includes('pago');
                                const currencyClass = isCurrency ? 'currency' : '';
                                
                                cardContent += `
                                    <div class="ios-card-detail-item">
                                        <span class="ios-detail-label">${label}:</span>
                                        <span class="ios-detail-value ${currencyClass}" data-type="${dataType}">${value}</span>
                                    </div>
                                `;
                            }
                        }
                        
                        cardContent += '</div>';
                        
                        // Verificar si hay botón de expansión para detalles
                        const toggleButton = row.querySelector('.toggle-clases, .toggle-details, [data-bs-toggle="collapse"]');
                        if (toggleButton) {
                            // Conservar acción original del botón
                            card.addEventListener('click', function(e) {
                                if (!e.target.closest('button, .btn, a')) {
                                    toggleButton.click();
                                }
                            });
                            
                            // Indicador visual de que hay más detalles
                            card.classList.add('has-details');
                            cardContent += `
                                <div class="ios-card-indicator">
                                    <i class="fas fa-chevron-down"></i>
                                </div>
                            `;
                        }
                        
                        card.innerHTML = cardContent;
                        cardsContainer.appendChild(card);
                        
                        // Agregar efecto de toque a la tarjeta
                        addTapEffect(card);
                        
                        // Agregar comportamiento para filas expandibles
                        const detailsRow = row.nextElementSibling;
                        if (detailsRow && detailsRow.classList.contains('clases-detalle')) {
                            // Crear elemento para detalles expandibles
                            const expandedDetails = document.createElement('div');
                            expandedDetails.className = 'ios-expanded-details';
                            expandedDetails.innerHTML = detailsRow.querySelector('td').innerHTML;
                            
                            // Insertar después de la tarjeta
                            card.appendChild(expandedDetails);
                            
                            // Sincronizar estados de expansión con los cambios en la fila original
                            const observer = new MutationObserver(function(mutations) {
                                mutations.forEach(function(mutation) {
                                    if (mutation.attributeName === 'class') {
                                        const isVisible = !detailsRow.classList.contains('d-none') && 
                                                          (detailsRow.classList.contains('show') || !detailsRow.classList.contains('collapse'));
                                        
                                        expandedDetails.classList.toggle('visible', isVisible);
                                        
                                        // Actualizar indicador
                                        const indicator = card.querySelector('.ios-card-indicator i');
                                        if (indicator) {
                                            indicator.className = isVisible ? 'fas fa-chevron-up' : 'fas fa-chevron-down';
                                        }
                                        
                                        // Actualizar estilo de la tarjeta
                                        card.classList.toggle('expanded', isVisible);
                                    }
                                });
                            });
                            
                            observer.observe(detailsRow, { attributes: true });
                        }
                    });
                }
                
                // Insertar vista de tarjetas antes de la tabla
                const tableContainer = table.closest('.table-responsive');
                if (tableContainer && tableContainer.parentNode) {
                    // Primero el encabezado
                    tableContainer.parentNode.insertBefore(tableHeader, tableContainer);
                    
                    // Luego la vista de tarjetas
                    tableContainer.parentNode.insertBefore(cardsContainer, tableContainer);
                    
                    // Agregar selector de vista mejorado
                    const viewToggle = document.createElement('div');
                    viewToggle.className = 'ios-view-toggle';
                    viewToggle.innerHTML = `
                        <button class="ios-view-btn active" data-view="card">
                            <i class="fas fa-th-large"></i> Tarjetas
                        </button>
                        <button class="ios-view-btn" data-view="table">
                            <i class="fas fa-table"></i> Tabla
                        </button>
                    `;
                    
                    // Agregar el toggle al header
                    const actionsContainer = tableHeader.querySelector('.ios-table-actions');
                    if (actionsContainer) {
                        actionsContainer.appendChild(viewToggle);
                        
                        // Escuchar clicks en los botones
                        const viewButtons = viewToggle.querySelectorAll('.ios-view-btn');
                        viewButtons.forEach(btn => {
                            btn.addEventListener('click', function() {
                                const view = this.getAttribute('data-view');
                                viewButtons.forEach(b => b.classList.remove('active'));
                                this.classList.add('active');
                                
                                if (view === 'card') {
                                    tableContainer.style.display = 'none';
                                    cardsContainer.style.display = 'flex';
                                } else {
                                    tableContainer.style.display = 'block';
                                    cardsContainer.style.display = 'none';
                                }
                            });
                            
                            // Añadir efecto visual al botón
                            addTapEffect(btn);
                        });
                    }
                    
                    // Estado inicial: mostrar tarjetas, ocultar tabla
                    tableContainer.style.display = 'none';
                }
            } catch (error) {
                console.error('Error al transformar tabla:', error, table);
            }
        });
    }
    
    /**
     * Mejora la visualización de filtros para reportes
     */
    function enhanceReportFilters() {
        // Buscar formularios de filtro
        const filterForms = document.querySelectorAll('form:has(select), form.filter-form, #seleccion-mes');
        
        filterForms.forEach(form => {
            if (form.getAttribute('data-ios-enhanced')) return;
            form.setAttribute('data-ios-enhanced', 'true');
            
            // Agregar clase para mejor estilo
            form.classList.add('ios-report-filters');
            form.classList.add('ios-fade-in');
            
            // Mejorar etiquetas y campos
            const formGroups = form.querySelectorAll('.form-group, .mb-3');
            formGroups.forEach(group => {
                const label = group.querySelector('label');
                if (label) {
                    label.classList.add('ios-filter-label');
                }
                
                // Mejorar selects
                const select = group.querySelector('select');
                if (select) {
                    select.classList.add('ios-select');
                    
                    // Crear envoltorio para estilo iOS
                    const selectWrapper = document.createElement('div');
                    selectWrapper.className = 'ios-select-wrapper';
                    select.parentNode.insertBefore(selectWrapper, select);
                    selectWrapper.appendChild(select);
                    
                    // Agregar icono de flecha
                    const arrowIcon = document.createElement('div');
                    arrowIcon.className = 'ios-select-arrow';
                    arrowIcon.innerHTML = '<i class="fas fa-chevron-down"></i>';
                    selectWrapper.appendChild(arrowIcon);
                    
                    // Agregar feedback táctil
                    select.addEventListener('focus', function() {
                        this.closest('.ios-select-wrapper').classList.add('focused');
                    });
                    
                    select.addEventListener('blur', function() {
                        this.closest('.ios-select-wrapper').classList.remove('focused');
                    });
                }
            });
            
            // Mejorar botones de acción
            const submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');
            if (submitBtn) {
                submitBtn.classList.add('ios-filter-action');
                
                // Reemplazar texto simple con versión mejorada
                const btnText = submitBtn.textContent.trim() || 'Filtrar';
                if (!submitBtn.querySelector('i')) {
                    submitBtn.innerHTML = `<i class="fas fa-filter"></i> ${btnText}`;
                }
                
                // Agregar feedback táctil
                submitBtn.addEventListener('click', function() {
                    addTapEffect(this);
                });
            }
        });
    }
    
    /**
     * Organiza botones de exportación
     */
    function organizeExportButtons() {
        // Buscar botones de exportación
        const exportButtons = document.querySelectorAll('.btn-export, [data-action="export"]');
        
        if (exportButtons.length > 0) {
            // Agrupar botones si no están ya agrupados
            let buttonsContainer = exportButtons[0].closest('.export-buttons, .btn-export-container');
            
            if (!buttonsContainer) {
                buttonsContainer = document.createElement('div');
                buttonsContainer.className = 'ios-export-buttons';
                
                // Insertar contenedor antes del primer botón
                exportButtons[0].parentNode.insertBefore(buttonsContainer, exportButtons[0]);
                
                // Mover botones al contenedor
                exportButtons.forEach(btn => {
                    buttonsContainer.appendChild(btn);
                    
                    // Agregar feedback táctil
                    btn.addEventListener('click', function() {
                        addTapEffect(this);
                    });
                    
                    // Simplificar texto de botón para usar solo iconos
                    const btnText = btn.textContent.trim();
                    const hasIcon = btn.querySelector('i');
                    
                    if (!hasIcon && btnText) {
                        // Crear icono basado en el tipo de exportación
                        let iconClass = 'fas fa-download';
                        
                        if (btnText.toLowerCase().includes('pdf')) {
                            iconClass = 'fas fa-file-pdf';
                        } else if (btnText.toLowerCase().includes('excel')) {
                            iconClass = 'fas fa-file-excel';
                        } else if (btnText.toLowerCase().includes('csv')) {
                            iconClass = 'fas fa-file-csv';
                        } else if (btnText.toLowerCase().includes('print')) {
                            iconClass = 'fas fa-print';
                        }
                        
                        // Crear icono y guardar texto original como tooltip
                        const span = document.createElement('span');
                        span.className = 'btn-text';
                        span.textContent = btnText;
                        
                        const icon = document.createElement('i');
                        icon.className = iconClass;
                        
                        btn.setAttribute('title', btnText);
                        btn.innerHTML = '';
                        btn.appendChild(icon);
                        btn.appendChild(span);
                    }
                });
            }
            
            // Añadir clases para mejor estilo
            buttonsContainer.classList.add('ios-export-container');
        }
    }
    
    /**
     * Mejora la visualización de gráficos si existen
     */
    function enhanceCharts() {
        // Buscar contenedores de gráficos
        const chartContainers = document.querySelectorAll('.chart-container, .chart, canvas, [id*="chart"], [id*="grafico"]');
        
        chartContainers.forEach(container => {
            if (container.getAttribute('data-ios-enhanced')) return;
            container.setAttribute('data-ios-enhanced', 'true');
            
            // No aplicar a canvas que son hijos de un contenedor que ya procesamos
            if (container.tagName === 'CANVAS' && 
                container.parentElement && 
                container.parentElement.getAttribute('data-ios-enhanced')) {
                return;
            }
            
            // Si es un canvas, envolver en un contenedor iOS
            if (container.tagName === 'CANVAS') {
                const wrapper = document.createElement('div');
                wrapper.className = 'ios-chart-container ios-fade-in';
                
                // Buscar un título cercano
                let title = '';
                const closestHeading = findClosestHeading(container);
                if (closestHeading) {
                    title = closestHeading.textContent.trim();
                }
                
                // Si encontramos un título, añadirlo
                if (title) {
                    const titleElement = document.createElement('div');
                    titleElement.className = 'ios-chart-title';
                    titleElement.textContent = title;
                    wrapper.appendChild(titleElement);
                }
                
                const chartWrapper = document.createElement('div');
                chartWrapper.className = 'ios-chart-wrapper';
                
                // Reemplazar el canvas original
                container.parentNode.insertBefore(wrapper, container);
                chartWrapper.appendChild(container);
                wrapper.appendChild(chartWrapper);
            } else {
                // Para otros contenedores, simplemente añadir clases iOS
                container.classList.add('ios-chart-container', 'ios-fade-in');
                
                // Si contiene un canvas, envolverlo en un wrapper para mejor control
                const canvas = container.querySelector('canvas');
                if (canvas) {
                    const chartWrapper = document.createElement('div');
                    chartWrapper.className = 'ios-chart-wrapper';
                    canvas.parentNode.insertBefore(chartWrapper, canvas);
                    chartWrapper.appendChild(canvas);
                }
            }
        });
    }
    
    /**
     * Agrega estados vacíos para elementos sin datos
     */
    function addEmptyStates() {
        // Buscar tablas vacías
        const emptyTables = document.querySelectorAll('table:not(.no-transform)');
        
        emptyTables.forEach(table => {
            const rowCount = table.querySelectorAll('tbody tr').length;
            
            if (rowCount === 0) {
                // Solo si la tabla no tiene ya un estado vacío personalizado
                if (!table.nextElementSibling || !table.nextElementSibling.classList.contains('ios-empty-state')) {
                    // Crear estado vacío
                    const emptyState = document.createElement('div');
                    emptyState.className = 'ios-empty-state';
                    
                    // Determinar un mensaje apropiado basado en el título o contenedor
                    let title = '';
                    let message = '';
                    
                    const closestHeading = findClosestHeading(table);
                    if (closestHeading) {
                        title = closestHeading.textContent.trim();
                        message = `No se encontraron registros para ${title.toLowerCase()}`;
                    } else {
                        title = 'No hay datos disponibles';
                        message = 'No se encontraron registros para mostrar';
                    }
                    
                    emptyState.innerHTML = `
                        <div class="ios-empty-state-icon">
                            <i class="fas fa-table"></i>
                        </div>
                        <div class="ios-empty-state-title">${title}</div>
                        <div class="ios-empty-state-text">${message}</div>
                    `;
                    
                    // Insertar después de la tabla
                    const tableContainer = table.closest('.table-responsive');
                    if (tableContainer) {
                        tableContainer.style.display = 'none';
                        tableContainer.parentNode.insertBefore(emptyState, tableContainer.nextSibling);
                    }
                }
            }
        });
    }
    
    /**
     * Optimiza la visualización de datos numéricos
     */
    function optimizeNumberDisplay() {
        // Buscar celdas con datos numéricos
        document.querySelectorAll('.ios-detail-value').forEach(valueElement => {
            const content = valueElement.textContent.trim();
            
            // Verificar si el contenido es numérico
            if (!isNaN(parseFloat(content)) && isFinite(content)) {
                valueElement.setAttribute('data-type', 'numeric');
                
                // Para valores monetarios, añadir formato especial
                if (content.includes('$') || content.includes('€') || content.includes('£')) {
                    valueElement.classList.add('currency');
                }
                
                // Para valores grandes, agregar separación de miles
                const numValue = parseFloat(content.replace(/[^\d.-]/g, ''));
                if (numValue >= 1000) {
                    valueElement.classList.add('large-number');
                }
                
                // Para percentages
                if (content.includes('%')) {
                    valueElement.classList.add('percentage');
                }
            }
        });
    }
    
    /**
     * Añade feedback táctil a un elemento interactivo
     */
    function addTapEffect(element) {
        if (!element) return;
        
        element.addEventListener('touchstart', function() {
            this.style.transform = 'scale(0.97)';
            this.style.transition = 'transform 0.1s ease';
        });
        
        const resetScale = function() {
            this.style.transform = 'scale(1)';
        };
        
        element.addEventListener('touchend', resetScale);
        element.addEventListener('touchcancel', resetScale);
    }
    
    /**
     * Encuentra el encabezado más cercano a un elemento
     */
    function findClosestHeading(element) {
        if (!element) return null;
        
        // Buscar en los hermanos anteriores
        let sibling = element.previousElementSibling;
        while (sibling) {
            if (sibling.tagName && sibling.tagName.match(/^H[1-6]$/)) {
                return sibling;
            }
            
            const heading = sibling.querySelector('h1, h2, h3, h4, h5, h6');
            if (heading) {
                return heading;
            }
            
            sibling = sibling.previousElementSibling;
        }
        
        // Buscar en el padre y sus hermanos
        const parent = element.parentNode;
        if (parent) {
            // Buscar en el padre primero
            const parentHeading = parent.querySelector('h1, h2, h3, h4, h5, h6');
            if (parentHeading && parent.contains(parentHeading) && !element.contains(parentHeading)) {
                return parentHeading;
            }
            
            // Intentar con los hermanos del padre
            return findClosestHeading(parent);
        }
        
        return null;
    }
    
    /**
     * Añade indicadores de desplazamiento horizontal para tablas
     */
    function addScrollIndicators() {
        const tableContainers = document.querySelectorAll('.table-responsive');
        
        tableContainers.forEach(container => {
            // Evitar transformaciones duplicadas
            if (container.hasAttribute('data-scroll-indicator')) return;
            container.setAttribute('data-scroll-indicator', 'true');
            
            // Detectar si hay desbordamiento horizontal
            if (container.scrollWidth > container.clientWidth) {
                // Añadir clase para estilos específicos
                container.classList.add('has-scroll');
            }
            
            // Actualizar el estado del indicador cuando el contenedor se desplaza
            container.addEventListener('scroll', function() {
                // Si ha llegado al final, ocultar el indicador
                if (this.scrollLeft + this.clientWidth >= this.scrollWidth - 5) {
                    this.classList.add('scroll-end');
                } else {
                    this.classList.remove('scroll-end');
                }
            });
        });
    }
    
    /**
     * Mejora la navegación entre secciones
     */
    function enhanceNavigation() {
        // Mejorar el botón de volver arriba si existe
        const backToTopBtn = document.getElementById('btn-back-to-top');
        
        if (backToTopBtn) {
            // Mejorar estilo del botón
            backToTopBtn.classList.add('ios-back-to-top');
            
            // Añadir efecto de toque
            addTapEffect(backToTopBtn);
            
            // Mejorar comportamiento de scroll
            backToTopBtn.addEventListener('click', function(e) {
                e.preventDefault();
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            });
        } else {
            // Crear un botón si no existe
            const newBackBtn = document.createElement('button');
            newBackBtn.id = 'btn-back-to-top';
            newBackBtn.className = 'btn btn-primary rounded-circle position-fixed ios-back-to-top';
            newBackBtn.style.bottom = '20px';
            newBackBtn.style.right = '20px';
            newBackBtn.style.display = 'none';
            newBackBtn.style.zIndex = '1000';
            newBackBtn.innerHTML = '<i class="fas fa-arrow-up"></i>';
            
            document.body.appendChild(newBackBtn);
            
            // Añadir efecto de toque
            addTapEffect(newBackBtn);
            
            // Manejar visibilidad del botón
            window.addEventListener('scroll', function() {
                if (window.pageYOffset > 300) {
                    newBackBtn.style.display = 'flex';
                } else {
                    newBackBtn.style.display = 'none';
                }
            });
            
            // Manejar click para volver arriba
            newBackBtn.addEventListener('click', function() {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            });
        }
        
        // Mejorar comportamiento de enlaces de navegación interna
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                const targetId = this.getAttribute('href');
                if (targetId === '#') return; // No hacer nada para enlaces "#"
                
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    e.preventDefault();
                    targetElement.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
            
            // Añadir efecto de toque
            addTapEffect(anchor);
        });
    }
}); 