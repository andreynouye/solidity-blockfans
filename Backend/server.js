require('dotenv').config();
const express = require('express');
const cors = require('cors');
const balanceRoutes = require('./routes/balance');
const cardsRouter = require('./routes/cards');
const clansRouter = require('./routes/clans');
const marketPlaceRoutes = require('./routes/marketplace');
const playerRoutes = require('./routes/player');
const worldsRoutes = require('./routes/worlds');
const errorHandler = require('./middlewares/errorHandler');

// Inicialize o express
const app = express();

// Use cors para permitir solicitações de cross-origin
app.use(cors());

// Endpoint para pegar o saldo de uma conta
app.use('/balance', balanceRoutes);
app.use('/cards', cardsRouter);
app.use('/clans', clansRouter);
app.use('/marketplace', marketPlaceRoutes);
app.use('/player', playerRoutes);
app.use('/worlds', worldsRoutes);

// Error handling middleware
app.use(errorHandler);

// Pega a porta do ambiente ou usa a porta 5050 como padrão
const port = process.env.PORT || 5050;

// Inicialize o servidor na porta especificada
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
