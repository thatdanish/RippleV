<center>

# Verification Coverage

</center>

Coverage data is generated using Verilator. To reproduce the data, run the command mentioned below, from the project root directory :
    
    make cover_<block name>

## Decoder

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   7/53      |     13.2 %    |
| Toggle      |   245/272   |     90.1 %    |
| Branch      |   4/18      |     22.2 %    |
| Expression  |   2/2       |     100 %     |

## Reg File

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   145/146   |     99.3 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

## Program Counter

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   25/26     |     96.2 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   4/4       |     100 %     |

## CSR

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   8/9       |     88.9 %    |
| Toggle      |   73/412    |     17.7 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

## Instruction Memory

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   2/2       |     100 %     |
| Toggle      |   73/80     |     91.2 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   2/2       |     100 %     |

## Data Memory

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   33/34     |     97.1 %    |
| Toggle      |   274/276   |     99.3 %    |
| Branch      |   7/10      |     70 %      |
| Expression  |   8/8       |     100 %     |