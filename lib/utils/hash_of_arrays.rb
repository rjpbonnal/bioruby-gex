class HashOfArrays < Hash

  #   order a list of ordered keys to use during the output
  #  
  #
  #tf_probes	4676104055_H	4676104055_I	4676104078_F	4676104078_G	4676104078_H	4676104078_I	4676104078_J	4676104078_K	4676104078_C	4676104078_D	4676104078_E	4676104055_J	4676104055_K	4676104055_L	4676104078_A	4676104078_B
  #ILMN_1651235	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
  #ILMN_1651262	2365.0	2709.1	1853.3	1865.9	1533.1	1870.9	2138.8	2150.3	1100.8	1746.1	2003.1	2304.7	2121.5	2672.1	1516.5	1375.8
  #ILMN_1651285	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
  #ILMN_1651315	693.9	283.4	356.4	375.2	247.9	510.4	276.6	250.0	346.1	687.7	341.9	312.4	284.5	359.4	1084.8	617.6
  #ILMN_1651347	1303.6	1756.7	1642.7	1338.6	1149.7	974.9	1677.6	1154.2	1043.8	1174.3	1410.3	1394.1	1595.4	1576.4	798.1	1274.4
  #ILMN_1651437	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
  #ILMN_1651438	290.4	299.4	628.9	355.4	473.8	485.8	504.6	331.9	707.6	395.4	476.5	431.8	479.6	590.3	510.7	542.4
  def transpose_to_str(number_first_lines, separator="\t", order=nil)
    keys_list= order || keys
    matrix_str=keys_list.join(separator)<<"\n"
    number_first_lines.times do |index|
      matrix_str+=keys_list.map do |name|
        self[name][index].to_s
      end.join(separator)
      matrix_str << "\n"
    end #times
    matrix_str
  end #function
end #class