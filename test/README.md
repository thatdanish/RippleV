<center>

# Verification Coverage

</center>

Coverage data is generated using Verilator. To reproduce the data, run the command mentioned below, from the project root directory :
    
    make cover_<block name>

## Block Level

### Decoder

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   44/53     |     83.0 %    |
| Toggle      |   247/272   |     90.8 %    |
| Branch      |   12/18     |     66.7 %    |
| Expression  |   2/2       |     100 %     |

### Reg File

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   145/146   |     99.3 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

### Program Counter

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   25/26     |     96.2 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   4/4       |     100 %     |

### CSR

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   8/9       |     88.9 %    |
| Toggle      |   73/412    |     17.7 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

### Instruction Memory

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   2/2       |     100 %     |
| Toggle      |   91/134    |     67.9 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   2/2       |     100 %     |

### Data Memory

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   19/19     |     100 %     |
| Toggle      |   168/204   |     82.4 %    |
| Branch      |   6/6       |     100 %     |
| Expression  |   2/2       |     100 %     |

### ALU

| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   33/34     |     97.1 %    |
| Toggle      |   274/276   |     99.3 %    |
| Branch      |   7/10      |     70 %      |
| Expression  |   8/8       |     100 %     |