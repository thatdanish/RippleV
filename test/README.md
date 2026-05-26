<center>

# Verification Coverage

</center>

Coverage data is generated using Verilator. To reproduce the data, run the command mentioned below, from the project root directory :
    
    make cover_<block name>

## Block Level

<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">

<div>

### Decoder
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   44/53     |     83.0 %    |
| Toggle      |   247/272   |     90.8 %    |
| Branch      |   12/18     |     66.7 %    |
| Expression  |   2/2       |     100 %     |

</div>
<div>

### Reg File
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   145/146   |     99.3 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

</div>
<div>

### Program Counter
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   25/26     |     96.2 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   4/4       |     100 %     |

</div>
<div>

### CSR
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   8/9       |     88.9 %    |
| Toggle      |   73/412    |     17.7 %    |
| Branch      |   8/8       |     100 %     |
| Expression  |   2/2       |     100 %     |

</div>
<div>

### Instruction Memory
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   2/2       |     100 %     |
| Toggle      |   73/80     |     91.2 %    |
| Branch      |   4/4       |     100 %     |
| Expression  |   2/2       |     100 %     |

</div>
<div>

### Data Memory
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   1/1       |     100 %     |
| Toggle      |   144/146   |     91.2 %    |
| Branch      |   6/6       |     100 %     |
| Expression  |   2/2       |     100 %     |

</div>
<div>

### ALU
| Type        | Coverage    | Percentage    |
|  :----:     |  :----:     |    :----:     |
| Line        |   33/34     |     97.1 %    |
| Toggle      |   274/276   |     99.3 %    |
| Branch      |   7/10      |     70 %      |
| Expression  |   8/8       |     100 %     |

</div>
</div>