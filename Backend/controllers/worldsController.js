const { superTrunfoContract } = require('../config/web3');

exports.getWorldScores = async (req, res, next) => {
    try {
        const playerAddresses = await superTrunfoContract.methods.getAvailablePlayers().call();

        const players = await Promise.all(playerAddresses.map(async (address) => {
            const playerDetails = await superTrunfoContract.methods.getPlayerDetails(address).call();
            playerDetails.address = address;
            return playerDetails;
        }));

        const groups = players.reduce((result, player) => {
            const landClass = player.landClass;

            // Ignore o jogador se o landClass não for uma string válida
            if (!landClass || typeof landClass !== 'string') {
                return result;
            }

            if (!result[landClass]) {
                result[landClass] = {
                    details: {
                        totalScore: 0,
                        totalAttackPoints: 0,
                        totalDefensePoints: 0,
                        playerCount: 0
                    }
                };
            }

            result[landClass].details.totalScore += parseInt(player.score);
            result[landClass].details.totalAttackPoints += parseInt(player.totalAttackPower);
            result[landClass].details.totalDefensePoints += parseInt(player.totalDefensePower);
            result[landClass].details.playerCount += 1;

            return result;
        }, {});

        // Transformando o objeto em um array e adicionando um índice
        const groupsArray = Object.keys(groups).map((key, index) => ({
            index: index,
            landClass: key,
            details: groups[key].details
        }));

        // Ordenando o array por 'totalScore'
        groupsArray.sort((a, b) => b.details.totalScore - a.details.totalScore);

        // Adicionando um índice
        groupsArray.forEach((group, index) => {
            group.index = index;
        });

        res.send(groupsArray);
    } catch (error) {
        next(error); // passa o erro para o middleware de manipulação de erros
    }
};