function obtenerDatosClimaticos(latitud, longitud, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitud}&longitude=${longitud}&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&hourly=temperature_2m,weather_code,precipitation_probability,uv_index,is_day&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,cloud_cover&timezone=auto&forecast_days=14&past_hours=24`;


    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                let datos = JSON.parse(req.responseText);
                callback(datos);
                console.log("data obtained")
            } else {
                console.error(`Error en la solicitud: weathergeneral ${req.status}`);
            }
        }
    };

    req.onerror = function () {
        console.error("Error de la red.");
        callback(null); // Devolver null en caso de error de red
    };

    req.send();
}

function getNameCity(latitude, longitud, leng, callback) {
    let url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${latitude}&lon=${longitud}&accept-language=${leng}`;

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    let address = datos.address;
                    let city = address.city;
                    let county = address.county;
                    let state = address.state;
                    let full = city ? city : state ? state : county;
                    console.log(full);
                    callback(full);
                } catch (e) {
                    console.error("Error al analizar la respuesta JSON: ", e);
                }
            } else {
                console.error(`city failed`);
            }
        }
    };

    req.onerror = function () {
        console.error("La solicitud falló");
    };

    req.ontimeout = function () {
        console.error("La solicitud excedió el tiempo de espera");
    };

    req.send();
}

function obtenerCoordenadas(callback) {
    let url = "http://ip-api.com/json/?fields=lat,lon";

    let req = new XMLHttpRequest();
    req.open("GET", url, true);

    req.onreadystatechange = function () {
        if (req.readyState === 4) {
            if (req.status === 200) {
                try {
                    let datos = JSON.parse(req.responseText);
                    console.log(`Coordenadas obtenidas:`);
                    callback(datos); // Devolver coordenadas completas
                } catch (error) {
                    console.error("Error procesando la respuesta JSON:", error);
                    callback(null); // Devolver null en caso de error de parsing
                }
            } else {
                console.error(`Error en la solicitud: ${req.status}`);
                callback(null); // Devolver null en caso de error de solicitud
            }
        }
    };

    req.onerror = function () {
        console.error("Error de red al intentar obtener coordenadas.");
        callback(null); // Devolver null en caso de error de red
    };

    req.send();
}
