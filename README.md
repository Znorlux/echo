# <!-- Banner aquí -->

<!-- Pon aquí una imagen/banner horizontal de tu app (por ejemplo en ./docs/banner.png) -->

(./echord-banner.png)

# Echord — OSINT & Exposure Viewer (Flutter)

Echord es una app Flutter para explorar hosts, servicios expuestos y vulnerabilidades usando un backend (Shodan-based). Incluye búsqueda avanzada con *presets*, escaneo puntual por IP/hostname, detalle enriquecido por host, y un sistema de favoritos con notas y tags.

---

## ✨ Características

* **Search (multihost):** busca por queries (e.g. `port:22 country:CO`, `product:"Apache httpd"`) con paginación e *infinite scroll*.
* **Scan (single host):** consulta directa por **IP/hostname** (usa el mismo endpoint que el detalle).
* **Host detail:** overview de IP/ISP/ORG/geo, resumen de riesgo, buckets de puertos, servicios (HTTP/TLS/CPE), y vulns.
* **Favorites:** guarda hosts con **alias, notas y tags**, edítalos y fíltalos.
* **Presets de búsqueda:** chips para lanzar queries comunes (HTTP 200, SSH expuesto, etc.).
* **UI/UX cuidada:** `GlowInput` con *glow* verde y una estética oscura consistente.
* **Actualizable al vuelo:** *pull-to-refresh* y botón de **Actualizar** en listas.

---

## 🧱 Stack

* **Flutter** (Dart)
* **http** para consumo de API REST
* **phosphor_flutter** para iconos
* **shared_preferences** para recordar últimos presets/ajustes locales

> Nota: No se requiere ningún *state manager* externo; la app usa `StatefulWidget` con estado local.

---

## 📦 Estructura del proyecto

```
lib/
  main.dart
  screens/
    search_screen.dart        # Búsqueda por query (paginada)
    scan_screen.dart          # Búsqueda directa por IP/hostname
    host_detail_screen.dart   # Detalle de un host
    favorites_list_screen.dart# Listado + filtro + paginación + editar
    favorite_form_screen.dart # Form para notas/tags de un favorito
  models/
    host.dart                 # Modelo tipado del host
    service.dart              # Modelo para servicios/banners
    summary.dart              # Modelo para el resumen/risk/portBuckets
  widgets/
    glow_input.dart           # Input con brillo y atajos de búsqueda
```

---

## 🔌 Backend utlizado (resumen de endpoints)

El backend original está en https://github.com/Znorlux/echord-backend

> Ajusta si tu API difiere. Estos son los que la app consume hoy.

* **Buscar múltiples hosts (query):**
  `GET /api/v1/shodan/search?q=<query>&page=<n>&size=<m>`
  **Respuesta esperada:** `{ data: [...], total: <int> }`

* **Host (IP/hostname):**
  `GET /api/v1/shodan/host/:ip`
  **Respuesta esperada:** `{ data: { ...host } }`

* **Favoritos:**

  * Listar: `GET /api/v1/favorites?search=&page=1&size=20` → `{ data: [...], total: <int> }`
  * Crear:  `POST /api/v1/favorites` → body `{ ip, alias, notes?, tags? }`
  * Obtener: `GET /api/v1/favorites/:id`
  * Actualizar: `PATCH /api/v1/favorites/:id` (o `PUT`)
  * Eliminar: `DELETE /api/v1/favorites/:id`

---

## ⚙️ Configuración rápida

1. **Clona** el repo y entra a la carpeta.

2. **Instala dependencias Flutter:**

   ```bash
   flutter pub get
   ```

3. **Configura la URL del backend.**
   En los archivos de pantalla verás una constante como:

   ```dart
   // Para dispositivo físico (misma red LAN):
   const String kBackendBase = 'http://<IP_DE_TU_PC>:4000';

   // Para emulador Android:
   // const String kBackendBase = 'http://10.0.2.2:4000';
   ```

   Reemplaza `<IP_DE_TU_PC>` por tu IP LAN (ej. `192.168.1.16`) o usa `10.0.2.2` si corres en emulador.

4. **Levanta tu backend** en `:4000`.

5. **Run**:

   ```bash
   flutter run
   ```

> Si deseas centralizar la base URL, crea `lib/core/config.dart` o usa `.env` con `flutter_dotenv`.

---

## 🧭 Uso

* **Search:** escribe una query (`service:http status:200`) y lanza con Enter o el botón del `GlowInput`. Usa los **presets** (chips) para inspirarte.
* **Scan:** escribe una **IP/hostname** y ve directo al **detalle**.
* **Host Detail:** explora overview, servicios (HTTP/TLS/CPE), vulns, y agrega/quita **favoritos** con el FAB ⭐.
* **Favorites:** filtra por IP/alias/tag, entra al *form* para añadir **notas y tags** o edítalos, y toca el item para ir al **detalle del host**.

---

## 🧪 Ejemplos CURL (para probar rápido tu backend)

* **Buscar**:

  ```bash
  curl "http://localhost:4000/api/v1/shodan/search?q=product:%22Apache%20httpd%22&page=1&size=20"
  ```

* **Host**:

  ```bash
  curl "http://localhost:4000/api/v1/shodan/host/scanme.nmap.org"
  ```

* **Favoritos**:

  ```bash
  # Crear
  curl -X POST "http://localhost:4000/api/v1/favorites" \
    -H "Content-Type: application/json" \
    -d '{"ip":"8.8.8.8","alias":"Google DNS","notes":"UDP/53 público","tags":["dns","google"]}'

  # Listar
  curl "http://localhost:4000/api/v1/favorites?search=&page=1&size=20"
  ```

---

## 🧩 Notas de implementación destacadas

* **Modelos tipados:** `Host`, `Summary`, `Service` evitan `Map<String,dynamic>` en UI.
* **UI de chips y cards:** `_chip(...)` y `_card(...)` homogenizan estilo.
* **Paginación en Search y Favorites:** control de `page/size/total` + botón “Cargar más”.
* **GlowInput flexible:** personaliza `prefixIcon`, `suffixIcon`, colores y *callbacks*.
* **Favoritos en Host Detail:** FAB detecta si la IP ya es favorita (consulta por `search=<ip>`), **POST** o **DELETE** según corresponda y brinda feedback con `SnackBar`.

---

## 🛠️ Troubleshooting

* **El emulador no ve `localhost`:** usa `http://10.0.2.2:4000`.
* **Dispositivo físico no conecta:** usa la **IP LAN de tu PC** y confirma que el firewall permita conexiones entrantes en `:4000`.
* **CORS (si pruebas desde web):** habilita CORS en el backend.
* **Tiempo de espera (timeout):** el cliente usa `http.get(...).timeout(...)`. Ajusta si tu backend tarda más.
* **Shodan API limits:** si tu backend proxyea Shodan, maneja cuotas/errores con mensajes claros.

---

## 🗺️ Roadmap

* [ ] Guardar/gestionar presets de búsqueda del usuario
* [ ] Exportar resultados (CSV/JSON)
* [ ] Modo *offline* para favoritos
* [ ] Filtros avanzados (chips dinámicos según *facets*)
* [ ] Soporte iOS + Web pulido
* [ ] Integrar “scan on-demand” (Shodan) desde la UI (si tu plan lo permite)

---

## 🤝 Contribuir

* Haz un fork, crea una rama `feature/<tu-feature>` y abre PR.
* Sigue la estética de UI actual y los modelos tipados en `lib/models/`.
* Añade capturas y ejemplos de API si tocas endpoints.

---

## 📄 Licencia

Este proyecto se publica bajo **MIT** (o la que elijas).
Incluye aquí el texto o un enlace a `LICENSE`.

---

## 📷 Screenshots

> (Opcional) Añade capturas en `./docs/` y enlázalas aquí.

* Search
* Scan
* Host detail
* Favorites list / form

---

## 🧠 Créditos

* Iconos de **Phosphor Icons**.
* Gracias a la comunidad OSINT y a Shodan por la inspiración técnica.

---

¿Te armo también un **CHANGELOG.md** y una **plantilla de issues**?
