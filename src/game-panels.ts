import { TitanesSystems, MISSION_LIST, JAEGERS } from './game-systems';

export function mountGamePanels(systems: TitanesSystems) {
  if (document.getElementById('titan-panels')) return;
  const host = document.createElement('div');
  host.id = 'titan-panels';
  host.innerHTML = `
    <nav class="tp-nav">
      <button data-panel="base">BASE</button><button data-panel="missions">CAMPAÑA</button><button data-panel="hangar">HANGAR</button><button data-panel="shop">TIENDA</button><button data-panel="alliance">ALIANZA</button>
    </nav>
    <section class="tp-window" aria-live="polite"><button class="tp-close">×</button><div class="tp-content"></div></section>`;
  document.body.appendChild(host);
  const windowEl = host.querySelector('.tp-window') as HTMLElement;
  const content = host.querySelector('.tp-content') as HTMLElement;
  const close = () => windowEl.classList.remove('open');
  host.querySelector('.tp-close')?.addEventListener('click', close);
  host.querySelectorAll('[data-panel]').forEach(btn => btn.addEventListener('click', () => render(btn.getAttribute('data-panel') || 'base')));
  function render(which: string) {
    windowEl.classList.add('open');
    const s = systems.snapshot();
    const baseLevel = 1 + Math.floor((s.upgrades.defense || 0) / 2);
    const res = `<div class="tp-res"><span>▰ ALEACIÓN <b>${s.resources.alloy}</b></span><span>◈ ENERGÍA <b>${s.resources.energy}</b></span><span>⌖ DATOS <b>${s.resources.intel}</b></span></div>`;
    if (which === 'base') {
      content.innerHTML = res + `<small>PPDC / SHATTERDOME</small><h2>BASE · NIVEL ${baseLevel}</h2><p>Construye instalaciones y prepara tu defensa. Mejorar defensas aumenta el nivel de base.</p><div class="tp-grid"><article><b>Centro de mando</b><span>Operaciones y desbloqueos</span><strong>NIVEL ${baseLevel}</strong></article><article><b>Hangar</b><span>Reparación y despliegue</span><strong>UNIDAD: ${JAEGERS[s.selectedJaeger].label}</strong></article><article><b>Generador</b><span>Producción energética</span><strong>REACTOR ${s.upgrades.reactor}</strong></article><article><b>Defensa perimetral</b><span>Protección de instalaciones</span><strong>NIVEL ${s.upgrades.defense}</strong></article><article><b>Taller</b><span>Mejora y mantenimiento</span><strong>ENTRENAMIENTO ${s.upgrades.training}</strong></article><article><b>Centro médico / evacuación</b><span>Protección de habitantes</span><strong>PERSONAL CIVIL: PROTEGIDO</strong></article></div><div class="tp-actions"><button data-up="defense">MEJORAR DEFENSA</button><button data-up="reactor">MEJORAR GENERADOR</button><button data-up="training">MEJORAR TALLER</button></div><p class="tp-note" id="tp-msg">Cada dos mejoras de defensa elevan un nivel de base de forma provisional.</p>`;
      content.querySelectorAll('[data-up]').forEach(b => b.addEventListener('click', () => { const r=systems.upgrade(b.getAttribute('data-up') as 'defense'|'reactor'|'training'); const msg=content.querySelector('#tp-msg'); if(msg) msg.textContent=r.ok?'Mejora completada. Nivel '+r.level:'Faltan recursos para esta mejora.'; render('base'); }));
    } else if (which === 'missions') {
      content.innerHTML = res + `<small>OPERACIONES / PACÍFICO</small><h2>CAMPAÑA PPDC</h2><p>Completa objetivos para conseguir recursos, experiencia y desbloquear la siguiente operación.</p><div class="tp-missions">${MISSION_LIST.map(m=>{const st=systems.missionStatus(m.id);return `<article class="${st.completed?'done':st.unlocked?'active':'locked'}"><div><small>${m.sector} · MISIÓN ${m.id}</small><b>${m.name}</b><span>${m.description}</span></div><button data-mission="${m.id}" ${(!st.current||st.completed)?'disabled':''}>${st.completed?'COMPLETADA':st.unlocked?'RECLAMAR VICTORIA':'BLOQUEADA'}</button></article>`}).join('')}</div>`;
      content.querySelectorAll('[data-mission]').forEach(b=>b.addEventListener('click',()=>{const id=Number(b.getAttribute('data-mission'));const result=systems.completeMission(id);if(result.ok){render('missions');}else {b.textContent='NO DISPONIBLE';}}));
    } else if (which === 'hangar') {
      content.innerHTML = res + `<small>UNIDADES / JAEGER PROGRAM</small><h2>HANGAR</h2><p>Selecciona una unidad disponible. Los desbloqueos superiores se habilitarán por progresión.</p><div class="tp-grid tp-jaegers">${Object.entries(JAEGERS).map(([id,j],i)=>`<article><b>${j.label}</b><span>${j.role} · PROTOTIPO</span><strong>ARMADURA ${j.armor} / POTENCIA ${j.power} / AGILIDAD ${j.agility}</strong><button data-jaeger="${id}" ${i>0?'disabled':''}>${s.selectedJaeger===id?'SELECCIONADO':'SELECCIONAR'}</button></article>`).join('')}</div>`;
      content.querySelectorAll('[data-jaeger]').forEach(b=>b.addEventListener('click',()=>{systems.setJaeger(b.getAttribute('data-jaeger') as 'gipsy'|'striker'|'cherno');render('hangar');}));
    } else if (which === 'shop') {
      content.innerHTML = res + `<small>ABASTECIMIENTO / PPDC</small><h2>TIENDA</h2><p>Catálogo provisional. Las compras usan los recursos guardados; inventario persistente se ampliará en la siguiente integración.</p><div class="tp-grid"><article><b>Kit de reparación · ${s.inventory.repairKit || 0}</b><span>Reabastecimiento de campo</span><strong>180 ALEACIÓN</strong><button data-buy="repair">ADQUIRIR</button></article><article><b>Componentes de armadura · ${s.inventory.armorParts || 0}</b><span>Material de mejora</span><strong>240 ALEACIÓN + 90 ENERGÍA</strong><button data-buy="armor">ADQUIRIR</button></article><article><b>Datos de investigación · ${s.inventory.researchData || 0}</b><span>Paquete de inteligencia</span><strong>120 ENERGÍA</strong><button data-buy="intel">ADQUIRIR</button></article></div><p id="tp-msg" class="tp-note"></p>`;
      content.querySelectorAll('[data-buy]').forEach(b=>b.addEventListener('click',()=>{const kind=b.getAttribute('data-buy');let ok=false;if(kind==='repair'){ok=systems.buyItem('repairKit',{alloy:180});}if(kind==='armor'){ok=systems.buyItem('armorParts',{alloy:240,energy:90});}if(kind==='intel'){ok=systems.buyItem('researchData',{energy:120});if(ok)systems.addResources({intel:2});}const msg=content.querySelector('#tp-msg');if(msg)msg.textContent=ok?'Compra completada.':'Recursos insuficientes.';render('shop');}));
    } else {
      content.innerHTML = res + `<small>DEFENSA COLECTIVA / COOPERACIÓN</small><h2>ALIANZA</h2><div class="tp-lock"><b>REQUISITO: BASE NIVEL 2 · ${baseLevel>=2?'DESBLOQUEADO':'BLOQUEADO'}</b><p>${baseLevel>=2?'Acceso de prototipo habilitado en esta interfaz. Las alianzas reales requieren backend y sincronización multijugador.':'Mejora la defensa dos veces para alcanzar base nivel 2. Esta interfaz todavía es local; la creación real de alianzas requiere servidor.'}</p></div><div class="tp-grid"><article><b>Crear alianza</b><span>Organiza una fuerza conjunta</span><strong>${baseLevel>=2?'PROTOTIPO LOCAL':'DESBLOQUEO BASE 2'}</strong></article><article><b>Buscar alianza</b><span>Encuentra otros comandantes</span><strong>CONEXIÓN MULTIJUGADOR PENDIENTE</strong></article><article><b>Operación conjunta</b><span>Protege ciudades y civiles</span><strong>PROTOTIPO FUTURO · ESCALA 40+ JAEGERS</strong></article></div>`;
    }
  }
}
