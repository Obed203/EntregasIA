// =========================================================================
// 1. FUNCIONES MATEMÁTICAS Y CONFIGURACIÓN DEL KERNEL
// =========================================================================

// Función de activación Sigmoide y su derivada matemática para actualizar pesos
const sigmoid = x => 1 / (1 + Math.exp(-x));
const dSigmoid = y => y * (1 - y);

/**
 * FUNCIÓN KERNEL: Ingeniería de características explícita.
 * Proyecta los datos de 2D a 3D añadiendo el término de interacción (x1 * x2)
 */
const aplicarKernel = (x1, x2) => {
    return [x1, x2, x1 * x2]; // Devuelve un array de 3 elementos estrictos: [x1, x2, z]
};

// Datos de entrenamiento estructurados con arrays tridimensionales reales
const trainingData = [
    { inputs: aplicarKernel(0, 0), output: [0] }, // Entrada en memoria: [0, 0, 0]
    { inputs: aplicarKernel(0, 1), output: [1] }, // Entrada en memoria: [0, 1, 0]
    { inputs: aplicarKernel(1, 0), output: [1] }, // Entrada en memoria: [1, 0, 0]
    { inputs: aplicarKernel(1, 1), output: [0] }  // Entrada en memoria: [1, 1, 1]
];

// =========================================================================
// 2. DECLARACIÓN E INICIALIZACIÓN DE VARIABLES DEL PERCEPTRÓN
// =========================================================================
// Inicializamos un array de 3 pesos numéricos flotantes aleatorios y un sesgo numérico
let weights = [Math.random(), Math.random(), Math.random()]; 
let bias = Math.random();
const learningRate = 0.5;

// Captura de elementos del DOM de la interfaz HTML
const btnTrain = document.getElementById('btnTrain');
const logDiv = document.getElementById('log');
const testSection = document.getElementById('testSection');
const x1Select = document.getElementById('x1');
const x2Select = document.getElementById('x2');
const predictionResult = document.getElementById('predictionResult');

function printLog(text) {
    logDiv.innerHTML += text + "<br>";
    logDiv.scrollTop = logDiv.scrollHeight;
}

// =========================================================================
// 3. FUNCIÓN DE PREDICCIÓN (PROCESAMIENTO DIRECTO EN 3D)
// =========================================================================
function predict(x1, x2) {
    // Obtenemos las características tridimensionales calculadas por el kernel
    const caracteristicas = aplicarKernel(x1, x2); 
    
    let sum = bias;
    for (let i = 0; i < weights.length; i++) {
        sum += caracteristicas[i] * weights[i];
    }
    
    return sigmoid(sum);
}

function updateUI() {
    const val1 = parseInt(x1Select.value);
    const val2 = parseInt(x2Select.value);
    const rawPrediction = predict(val1, val2);
    const rounded = Math.round(rawPrediction);
    
    predictionResult.innerHTML = `
        Predicción: <strong>${rawPrediction.toFixed(4)}</strong> <br>
        Resultado (Redondeado): <span style="color: #007bff; font-size: 24px;">${rounded}</span>
    `;
}

x1Select.addEventListener('change', updateUI);
x2Select.addEventListener('change', updateUI);

// =========================================================================
// 4. BUCLE DE ENTRENAMIENTO Y CORRECCIÓN DE SALIDA DE LOGS
// =========================================================================
btnTrain.addEventListener('click', () => {
    btnTrain.disabled = true;

    setTimeout(() => {
        // Ejecución de las épocas de entrenamiento para actualizar pesos y sesgos
        for (let epoch = 0; epoch < 20000; epoch++) {
            for (let data of trainingData) {
            
                let sum = bias;
                for (let i = 0; i < weights.length; i++) {
                    sum += data.inputs[i] * weights[i];
                }
                let predictedOutput = sigmoid(sum);

                // Cálculo del error numérico real y del gradiente local
                let error = data.output[0] - predictedOutput;
                let gradient = error * dSigmoid(predictedOutput) * learningRate;

                // Modificación del array de pesos numéricos sin romper la dimensionalidad
                for (let i = 0; i < weights.length; i++) {
                    weights[i] += gradient * data.inputs[i];
                }
                bias += gradient;
            }
        }

        printLog("<br>Resultados Exitosos:");
        
        // CORRECCIÓN CLAVE: Extraemos los datos del array 3D almacenado en memoria de forma limpia
        trainingData.forEach((data) => {
            const x1 = data.inputs[0];
            const x2 = data.inputs[1];
            const z  = data.inputs[2];
            
            // Calculamos la predicción usando las variables nativas 2D
            let res = predict(x1, x2);
            
            printLog(`Entradas originales: [${x1}, ${x2}] -> Con Kernel Z: [${x1}, ${x2}, ${z}] | Esperado: ${data.output[0]} | Predicción: ${res.toFixed(4)}`);
        });

        // Impresión en pantalla de la ecuación matemática del hiperplano sin valores NaN
        printLog("<br><strong>Ecuación para GeoGebra 3D Calculator:</strong>");
        printLog(`Formula: ${weights[0].toFixed(2)}*x + ${weights[1].toFixed(2)}*y + ${weights[2].toFixed(2)}*z + (${bias.toFixed(2)}) = 0.5`);
        
        testSection.style.display = 'block';
        updateUI();
        btnTrain.textContent = "Entrenamiento finalizado";
    }, 50);
});