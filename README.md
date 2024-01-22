# docker-palworld-server

Creates a Palworld Server in Docker

#WIP. TL;DR

## Environment Variables

| Name                | Default | Description                                            |
|---------------------|---------|--------------------------------------------------------|
| `UPDATE_ON_START`   | `false` | Updates the PalWorld server when the container starts. |
| `COMMMUNITY_SERVER` | `false` | Lists the server under "Community Servers".            |
| `CFG_<ConfigValue>` |         | Read Below about CFG_ Variables.                       |

### `CFG_` Variables

You can edit config file variables from: [Here](https://tech.palworldgame.com/optimize-game-balance).
For example:

Variable: ExpRate
`docker -e CFG_ExpRate=10 docker-palworld-server`