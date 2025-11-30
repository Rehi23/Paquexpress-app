-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 30-11-2025 a las 07:55:46
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `paquexpress_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `agentes`
--

CREATE TABLE `agentes` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `nombre_completo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `agentes`
--

INSERT INTO `agentes` (`id`, `username`, `password_hash`, `nombre_completo`) VALUES
(1, 'agente01', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxwKc.6qKzJbG.M5q/..', 'Juan Pérez'),
(2, 'rehi', '$2b$12$XhpuHfkp5WFIZFeHLy.mMewBuKLdEP33sO/l7TmRGP386cxFseXXy', 'Regina Sanchez'),
(3, 'agente02', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxwKc.6qKzJbG.M5q/..', 'Maria Gonzalez');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paquetes`
--

CREATE TABLE `paquetes` (
  `id` int(11) NOT NULL,
  `direccion_destino` varchar(200) NOT NULL,
  `latitud_destino` double DEFAULT NULL,
  `longitud_destino` double DEFAULT NULL,
  `estado` enum('pendiente','entregado') DEFAULT 'pendiente',
  `agente_asignado_id` int(11) DEFAULT NULL,
  `fecha_entrega` datetime DEFAULT NULL,
  `evidencia_foto_url` varchar(255) DEFAULT NULL,
  `latitud_entrega` double DEFAULT NULL,
  `longitud_entrega` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `paquetes`
--

INSERT INTO `paquetes` (`id`, `direccion_destino`, `latitud_destino`, `longitud_destino`, `estado`, `agente_asignado_id`, `fecha_entrega`, `evidencia_foto_url`, `latitud_entrega`, `longitud_entrega`) VALUES
(1, 'Av. Reforma 222, CDMX', 19.4294, -99.163, 'entregado', 2, NULL, 'uploads/c6beaf17-daaf-4420-873f-4a1a1705a5986702182585791775224.jpg', 20.6311597, -100.4638204),
(2, 'Calle Madero 10, QRO', 20.5937, -100.3906, 'entregado', 2, NULL, 'uploads/8055d804-7a83-4b9a-8eb5-7e59ce5755a72820145278719112983.jpg', 20.6311658, -100.463816),
(3, 'Av. Constituyentes 12, Querétaro Centro', 20.5925, -100.39, 'entregado', 2, '2025-11-30 00:32:46', 'uploads/ace8c4b4-2a7b-4b05-a878-a2a7885017228785066125985102594.jpg', 20.6311753, -100.4638094),
(4, 'Blvd. Bernardo Quintana 400, QRO', 20.612, -100.405, 'entregado', 2, '2025-11-30 00:34:56', 'uploads/336fbcbb-e509-4b8e-a1b9-2baa99c533709173796191662053678.jpg', 20.6311753, -100.4638094),
(5, 'Plaza de Armas, Centro Histórico QRO', 20.593, -100.389, 'entregado', 2, '2025-11-30 00:46:10', 'uploads/da8ca6ea-9be7-4bb3-8423-1191c1d55f022913464870956381148.jpg', 20.6311753, -100.4638094),
(6, 'Universidad Anáhuac QRO, Circuito Universidades', 20.655, -100.355, 'pendiente', 2, NULL, NULL, NULL, NULL),
(7, 'Juriquilla Towers, Santa Fe', 20.692, -100.435, 'pendiente', 2, NULL, NULL, NULL, NULL),
(8, 'Museo Soumaya, Polanco CDMX', 19.4407, -99.2047, 'pendiente', 1, NULL, NULL, NULL, NULL),
(9, 'Palacio de Bellas Artes, Centro CDMX', 19.4352, -99.1412, 'pendiente', 1, NULL, NULL, NULL, NULL),
(10, 'Estadio Azteca, Tlalpan CDMX', 19.3029, -99.1505, 'pendiente', 3, NULL, NULL, NULL, NULL),
(11, 'Parque La Mexicana, Santa Fe CDMX', 19.357, -99.277, 'pendiente', 1, NULL, NULL, NULL, NULL),
(12, 'Coyoacán Centro, Jardín Hidalgo', 19.351, -99.162, 'pendiente', 3, NULL, NULL, NULL, NULL),
(13, 'Los Arcos de Querétaro (Mirador)', 20.5955, -100.3783, 'pendiente', 1, NULL, NULL, NULL, NULL),
(14, 'Alameda Hidalgo, Centro Histórico', 20.5902, -100.394, 'pendiente', 2, NULL, NULL, NULL, NULL),
(15, 'Centro Cívico, Centro Sur', 20.5624, -100.3695, 'pendiente', 2, NULL, NULL, NULL, NULL),
(16, 'Fraccionamiento Milenio III', 20.5978, -100.3551, 'pendiente', 1, NULL, NULL, NULL, NULL),
(17, 'Terminal de Autobuses (TAQ)', 20.5695, -100.365, 'pendiente', 3, NULL, NULL, NULL, NULL),
(18, 'Estadio Corregidora', 20.5744, -100.3752, 'pendiente', 2, NULL, NULL, NULL, NULL);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `agentes`
--
ALTER TABLE `agentes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `paquetes`
--
ALTER TABLE `paquetes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `agente_asignado_id` (`agente_asignado_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `agentes`
--
ALTER TABLE `agentes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `paquetes`
--
ALTER TABLE `paquetes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `paquetes`
--
ALTER TABLE `paquetes`
  ADD CONSTRAINT `paquetes_ibfk_1` FOREIGN KEY (`agente_asignado_id`) REFERENCES `agentes` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
