/**
 * iOS Style - Script principal para transformar la interfaz de la aplicación 
 * a un estilo similar a iOS nativo en dispositivos móviles
 */
document.addEventListener('DOMContentLoaded', function() {
    // Solo aplicar en dispositivos móviles
    const isMobile = window.innerWidth <= 768;
    
    if (isMobile) {
        console.log('Transformando interfaz a estilo iOS');
        
        // Agregar clase general iOS al body si no existe ya
        if (!document.body.classList.contains('ios-style')) {
            document.body.classList.add('ios-style');
        }
        
        // Verificar si estamos en la sección de informes
        const isReportPage = window.location.pathname.includes('/informe') || 
                             document.title.includes('Informe') ||
                             document.querySelector('h1, h2')?.textContent.includes('Informe');
        
        // Si estamos en la sección de informes, dejamos que reports-ios.js se encargue
        // de la transformación específica de esa sección
        if (isReportPage) {
            console.log('Aplicando mejoras iOS a la sección de informes');
            return; // Salir y dejar que reports-ios.js se encargue
        }
        
        // Para el resto de la aplicación, aplicar transformaciones generales
        applyIOSStyles();
    }
    
    /**
     * Aplica estilos iOS generales a toda la aplicación
     */
    function applyIOSStyles() {
        // Mejorar encabezado
        enhanceHeader();
        
        // Mejorar tarjetas
        enhanceCards();
        
        // Mejorar botones
        enhanceButtons();
        
        // Mejorar formularios
        enhanceForms();
        
        // Mejorar tablas generales (no de reportes)
        enhanceTables();
        
        // Agregar soporte para gestos
        enableGestures();
        
        // Mejorar navegación
        createBottomNav();
    }
    
    /**
     * Mejora el encabezado para que se parezca a un encabezado de iOS
     */
    function enhanceHeader() {
        const headers = document.querySelectorAll('.navbar, header, .app-header');
        
        headers.forEach(header => {
            // Evitar aplicar múltiples veces
            if (header.classList.contains('ios-enhanced')) return;
            header.classList.add('ios-enhanced');
            
            // Agregar clases iOS
            header.classList.add('ios-header');
            
            // Ajustar altura y espaciado
            header.style.height = 'auto';
            header.style.paddingTop = '10px';
            header.style.paddingBottom = '10px';
            
            // Estilizar título de encabezado
            const title = header.querySelector('.navbar-brand, .brand, .title, h1');
            if (title) {
                title.classList.add('ios-header-title');
                title.style.fontSize = '18px';
                title.style.fontWeight = '600';
                title.style.textAlign = 'center';
                
                // Centrar título
                const container = title.closest('.container, .container-fluid, .row');
                if (container) {
                    container.style.display = 'flex';
                    container.style.justifyContent = 'center';
                    container.style.alignItems = 'center';
                }
            }
            
            // Mejorar botones de encabezado
            const headerButtons = header.querySelectorAll('button, .btn');
            headerButtons.forEach(btn => {
                btn.classList.add('ios-header-button');
                btn.style.minWidth = '44px';
                btn.style.minHeight = '44px';
                btn.style.padding = '0 10px';
                btn.style.display = 'flex';
                btn.style.alignItems = 'center';
                btn.style.justifyContent = 'center';
            });
        });
    }
    
    /**
     * Mejora las tarjetas para que se parezcan a las de iOS
     */
    function enhanceCards() {
        const cards = document.querySelectorAll('.card');
        
        cards.forEach(card => {
            // Evitar aplicar múltiples veces
            if (card.classList.contains('ios-enhanced')) return;
            card.classList.add('ios-enhanced');
            
            // Agregar clases iOS
            card.classList.add('ios-card');
            
            // Ajustar estilos
            card.style.borderRadius = '13px';
            card.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.08)';
            card.style.border = 'none';
            card.style.overflow = 'hidden';
            
            // Ajustar cabecera
            const cardHeader = card.querySelector('.card-header');
            if (cardHeader) {
                cardHeader.classList.add('ios-card-header');
                cardHeader.style.borderBottom = '1px solid rgba(0, 0, 0, 0.05)';
                cardHeader.style.backgroundColor = 'white';
                cardHeader.style.padding = '15px';
                
                const cardTitle = cardHeader.querySelector('.card-title, h3, h4, h5');
                if (cardTitle) {
                    cardTitle.style.fontSize = '17px';
                    cardTitle.style.fontWeight = '600';
                    cardTitle.style.margin = '0';
                }
            }
            
            // Ajustar cuerpo
            const cardBody = card.querySelector('.card-body');
            if (cardBody) {
                cardBody.classList.add('ios-card-body');
                cardBody.style.padding = '15px';
            }
            
            // Ajustar pie
            const cardFooter = card.querySelector('.card-footer');
            if (cardFooter) {
                cardFooter.classList.add('ios-card-footer');
                cardFooter.style.borderTop = '1px solid rgba(0, 0, 0, 0.05)';
                cardFooter.style.backgroundColor = 'white';
                cardFooter.style.padding = '15px';
            }
        });
    }
    
    /**
     * Mejora los botones para que se parezcan a los de iOS
     */
    function enhanceButtons() {
        const buttons = document.querySelectorAll('button, .btn');
        
        buttons.forEach(btn => {
            // Evitar aplicar a botones que ya estén en un encabezado o pie de tarjeta
            if (btn.closest('.ios-header, .ios-card-footer, .navbar, .ios-enhanced')) return;
            
            // Evitar aplicar múltiples veces
            if (btn.classList.contains('ios-enhanced')) return;
            btn.classList.add('ios-enhanced');
            
            // Agregar clases iOS
            btn.classList.add('ios-button');
            
            // Ajustar tamaño para táctil
            if (btn.offsetWidth < 44 || btn.offsetHeight < 44) {
                btn.style.minWidth = '44px';
                btn.style.minHeight = '44px';
            }
            
            // Para botones primarios
            if (btn.classList.contains('btn-primary')) {
                btn.style.backgroundColor = '#007aff';
                btn.style.borderColor = '#007aff';
                btn.style.borderRadius = '10px';
                btn.style.fontWeight = '500';
                
                // Escuchar eventos para feedback visual
                btn.addEventListener('touchstart', function() {
                    this.style.transform = 'scale(0.97)';
                    this.style.backgroundColor = '#0062cc';
                });
                
                btn.addEventListener('touchend', function() {
                    this.style.transform = 'scale(1)';
                    this.style.backgroundColor = '#007aff';
                });
            }
            
            // Para botones secundarios
            if (btn.classList.contains('btn-secondary')) {
                btn.style.backgroundColor = '#f2f2f7';
                btn.style.borderColor = '#e5e5ea';
                btn.style.color = '#8e8e93';
                btn.style.borderRadius = '10px';
                
                // Escuchar eventos para feedback visual
                btn.addEventListener('touchstart', function() {
                    this.style.transform = 'scale(0.97)';
                    this.style.backgroundColor = '#e5e5ea';
                });
                
                btn.addEventListener('touchend', function() {
                    this.style.transform = 'scale(1)';
                    this.style.backgroundColor = '#f2f2f7';
                });
            }
        });
    }
    
    /**
     * Mejora los formularios para que se parezcan a los de iOS
     */
    function enhanceForms() {
        // Mejorar campos de texto
        const inputs = document.querySelectorAll('input[type="text"], input[type="email"], input[type="password"], textarea');
        
        inputs.forEach(input => {
            // Evitar aplicar múltiples veces
            if (input.classList.contains('ios-enhanced')) return;
            input.classList.add('ios-enhanced');
            
            // Agregar clases iOS
            input.classList.add('ios-input');
            
            // Ajustar estilos
            input.style.borderRadius = '10px';
            input.style.height = '44px';
            input.style.fontSize = '16px';
            input.style.padding = '0 12px';
            input.style.border = '1px solid #e5e5ea';
            input.style.backgroundColor = '#f9f9fb';
            
            // Ajustar versión foco
            input.addEventListener('focus', function() {
                this.style.borderColor = '#007aff';
                this.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.2)';
            });
            
            input.addEventListener('blur', function() {
                this.style.borderColor = '#e5e5ea';
                this.style.boxShadow = 'none';
            });
        });
        
        // Mejorar selects
        const selects = document.querySelectorAll('select');
        
        selects.forEach(select => {
            // Evitar aplicar múltiples veces o a selects ya mejorados
            if (select.classList.contains('ios-enhanced') || select.classList.contains('ios-select')) return;
            select.classList.add('ios-enhanced');
            
            // Crear envoltorio para estilo iOS
            const wrapper = document.createElement('div');
            wrapper.className = 'ios-select-wrapper';
            wrapper.style.position = 'relative';
            
            // Agregar clases iOS
            select.classList.add('ios-select');
            
            // Ajustar estilos
            select.style.appearance = 'none';
            select.style.webkitAppearance = 'none';
            select.style.height = '44px';
            select.style.fontSize = '16px';
            select.style.padding = '0 30px 0 12px';
            select.style.width = '100%';
            select.style.border = '1px solid #e5e5ea';
            select.style.backgroundColor = '#f9f9fb';
            select.style.borderRadius = '10px';
            select.style.backgroundImage = 'none';
            
            // Reemplazar select con wrapper
            select.parentNode.insertBefore(wrapper, select);
            wrapper.appendChild(select);
            
            // Agregar icono de flecha
            const arrow = document.createElement('div');
            arrow.className = 'ios-select-arrow';
            arrow.style.position = 'absolute';
            arrow.style.top = '50%';
            arrow.style.right = '12px';
            arrow.style.transform = 'translateY(-50%)';
            arrow.style.pointerEvents = 'none';
            arrow.innerHTML = '<i class="fas fa-chevron-down" style="font-size:12px; color:#8e8e93;"></i>';
            
            wrapper.appendChild(arrow);
            
            // Ajustar versión foco
            select.addEventListener('focus', function() {
                this.style.borderColor = '#007aff';
                this.style.boxShadow = '0 0 0 3px rgba(0, 122, 255, 0.2)';
                arrow.querySelector('i').style.transform = 'rotate(180deg)';
            });
            
            select.addEventListener('blur', function() {
                this.style.borderColor = '#e5e5ea';
                this.style.boxShadow = 'none';
                arrow.querySelector('i').style.transform = 'rotate(0)';
            });
        });
    }
    
    /**
     * Mejora las tablas para que se parezcan a las de iOS
     */
    function enhanceTables() {
        // No modificar tablas en páginas de informes
        const isReportPage = window.location.pathname.includes('/informe') || 
                           document.title.includes('Informe') ||
                           document.querySelector('h1, h2')?.textContent.includes('Informe');
        
        if (isReportPage) return;
        
        const tables = document.querySelectorAll('table:not(.ios-enhanced)');
        
        tables.forEach(table => {
            // Evitar aplicar múltiples veces
            if (table.classList.contains('ios-enhanced')) return;
            table.classList.add('ios-enhanced');
            
            // Agregar clases iOS
            table.classList.add('ios-table');
            
            // Asegurar que la tabla sea responsive
            const tableParent = table.parentNode;
            let responsiveWrapper;
            
            if (!tableParent.classList.contains('table-responsive')) {
                responsiveWrapper = document.createElement('div');
                responsiveWrapper.className = 'table-responsive ios-table-responsive';
                tableParent.insertBefore(responsiveWrapper, table);
                responsiveWrapper.appendChild(table);
            } else {
                responsiveWrapper = tableParent;
                responsiveWrapper.classList.add('ios-table-responsive');
            }
            
            // Estilizar tabla como iOS
            table.style.borderCollapse = 'separate';
            table.style.borderSpacing = '0';
            table.style.width = '100%';
            
            // Ajustar cabecera
            const thead = table.querySelector('thead');
            if (thead) {
                thead.style.backgroundColor = '#f9f9fb';
                
                const headerCells = thead.querySelectorAll('th');
                headerCells.forEach(th => {
                    th.style.fontSize = '14px';
                    th.style.fontWeight = '600';
                    th.style.color = '#8e8e93';
                    th.style.textAlign = 'left';
                    th.style.padding = '12px 15px';
                    th.style.borderBottom = '1px solid #e5e5ea';
                });
            }
            
            // Ajustar cuerpo
            const tbody = table.querySelector('tbody');
            if (tbody) {
                const rows = tbody.querySelectorAll('tr');
                rows.forEach((tr, index) => {
                    // Aplicar color alternado
                    if (index % 2 === 1) {
                        tr.style.backgroundColor = '#f9f9fb';
                    } else {
                        tr.style.backgroundColor = 'white';
                    }
                    
                    // Estilizar celdas
                    const cells = tr.querySelectorAll('td');
                    cells.forEach(td => {
                        td.style.fontSize = '15px';
                        td.style.padding = '12px 15px';
                        td.style.borderBottom = '1px solid #f2f2f7';
                        td.style.color = '#1c1c1e';
                        td.style.verticalAlign = 'middle';
                    });
                });
            }
            
            // Agregar indicador de desplazamiento horizontal si es necesario
            if (table.offsetWidth > responsiveWrapper.offsetWidth) {
                const scrollIndicator = document.createElement('div');
                scrollIndicator.className = 'ios-table-scroll-indicator';
                scrollIndicator.style.position = 'absolute';
                scrollIndicator.style.bottom = '10px';
                scrollIndicator.style.right = '10px';
                scrollIndicator.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
                scrollIndicator.style.color = 'white';
                scrollIndicator.style.borderRadius = '15px';
                scrollIndicator.style.padding = '5px 10px';
                scrollIndicator.style.fontSize = '12px';
                scrollIndicator.style.opacity = '0.8';
                scrollIndicator.style.transition = 'opacity 0.3s ease';
                scrollIndicator.innerHTML = '<i class="fas fa-arrows-left-right"></i> Desliza para ver más';
                
                // Posicionar el indicador
                responsiveWrapper.style.position = 'relative';
                responsiveWrapper.appendChild(scrollIndicator);
                
                // Ocultar el indicador cuando se desplaza
                responsiveWrapper.addEventListener('scroll', function() {
                    scrollIndicator.style.opacity = '0';
                    setTimeout(() => {
                        scrollIndicator.remove();
                    }, 300);
                });
            }
        });
    }
    
    /**
     * Habilita soporte para gestos al estilo iOS
     */
    function enableGestures() {
        // Detectar si la página tiene navegación hacia atrás
        const backLinks = document.querySelectorAll('a[href*="back"], a[href*="volver"], a:has(i.fa-chevron-left), a:has(i.fa-arrow-left)');
        
        if (backLinks.length > 0) {
            // Agregar soporte para deslizar hacia la derecha para volver atrás
            let startX, startY, dist, threshold = 100;
            let allowedTime = 300, startTime;
            
            document.addEventListener('touchstart', function(e) {
                const touchobj = e.changedTouches[0];
                startX = touchobj.pageX;
                startY = touchobj.pageY;
                startTime = new Date().getTime();
            }, false);
            
            document.addEventListener('touchend', function(e) {
                const touchobj = e.changedTouches[0];
                dist = touchobj.pageX - startX;
                const elapsedTime = new Date().getTime() - startTime;
                
                // Comprobar si el gesto es un deslizamiento horizontal rápido
                const verticalDist = Math.abs(touchobj.pageY - startY);
                
                if (elapsedTime <= allowedTime && dist > threshold && verticalDist < 100) {
                    // Deslizamiento hacia la derecha -> volver atrás
                    backLinks[0].click();
                }
            }, false);
        }
    }
    
    /**
     * Crea una barra de navegación inferior estilo iOS
     */
    function createBottomNav() {
        // Verificar si ya existe una navegación principal
        const mainNav = document.querySelector('nav.navbar, .navigation, .main-menu');
        
        if (!mainNav) return;
        
        // Verificar si debemos crear navegación inferior
        const navItems = mainNav.querySelectorAll('.nav-item, .menu-item, a.nav-link');
        
        if (navItems.length < 2 || navItems.length > 5) return; // Solo crear para 2-5 elementos
        
        // Evitar crear duplicados
        if (document.querySelector('.ios-bottom-nav')) return;
        
        // Crear navegación inferior
        const bottomNav = document.createElement('div');
        bottomNav.className = 'ios-bottom-nav';
        bottomNav.style.position = 'fixed';
        bottomNav.style.bottom = '0';
        bottomNav.style.left = '0';
        bottomNav.style.width = '100%';
        bottomNav.style.backgroundColor = 'white';
        bottomNav.style.borderTop = '1px solid #e5e5ea';
        bottomNav.style.display = 'flex';
        bottomNav.style.justifyContent = 'space-around';
        bottomNav.style.padding = '10px 0';
        bottomNav.style.zIndex = '1000';
        
        // Crear elementos de navegación
        navItems.forEach(item => {
            const link = item.querySelector('a') || item;
            const navText = link.textContent.trim();
            const href = link.getAttribute('href') || '#';
            
            // Determinar si es activo
            const isActive = (
                link.classList.contains('active') || 
                item.classList.contains('active') || 
                href === window.location.pathname
            );
            
            // Crear icono según texto
            let iconClass = 'fas fa-home';
            
            if (navText.toLowerCase().includes('inicio')) {
                iconClass = 'fas fa-home';
            } else if (navText.toLowerCase().includes('perfil')) {
                iconClass = 'fas fa-user';
            } else if (navText.toLowerCase().includes('informe')) {
                iconClass = 'fas fa-chart-bar';
            } else if (navText.toLowerCase().includes('profesor')) {
                iconClass = 'fas fa-chalkboard-teacher';
            } else if (navText.toLowerCase().includes('clase')) {
                iconClass = 'fas fa-dumbbell';
            } else if (navText.toLowerCase().includes('config')) {
                iconClass = 'fas fa-cog';
            } else if (navText.toLowerCase().includes('salir')) {
                iconClass = 'fas fa-sign-out-alt';
            }
            
            // Crear elemento de navegación
            const navItem = document.createElement('a');
            navItem.href = href;
            navItem.className = 'ios-bottom-nav-item';
            navItem.style.display = 'flex';
            navItem.style.flexDirection = 'column';
            navItem.style.alignItems = 'center';
            navItem.style.textDecoration = 'none';
            navItem.style.color = isActive ? '#007aff' : '#8e8e93';
            navItem.style.fontSize = '10px';
            navItem.style.padding = '5px';
            navItem.style.minWidth = '60px';
            
            navItem.innerHTML = `
                <i class="${iconClass}" style="font-size: 22px; margin-bottom: 4px;"></i>
                <span>${navText}</span>
            `;
            
            // Agregar efecto en clic
            navItem.addEventListener('touchstart', function() {
                this.style.transform = 'scale(0.92)';
            });
            
            navItem.addEventListener('touchend', function() {
                this.style.transform = 'scale(1)';
            });
            
            bottomNav.appendChild(navItem);
        });
        
        // Agregar navegación al cuerpo
        document.body.appendChild(bottomNav);
        
        // Ajustar espaciado inferior para contenedor principal
        const mainContent = document.querySelector('main, .container, .container-fluid');
        if (mainContent) {
            mainContent.style.paddingBottom = '70px';
        }
    }
}); 