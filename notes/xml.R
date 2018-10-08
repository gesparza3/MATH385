## Load libraries
library(xml2)

################################################################################

## Creating tree
l <- list(1:6, 5, 'edward') # You can also assign names to objects(ex: list(num = 5))

################################################################################

### Using xml

## Read xml
cd <- read_xml(xml2_example('cd_catalog.xml'))
# <CATALOG>
#   <CD>
#     <TITLE>
#       {text}
#     <ARTIST>
#       {text}
#     <COUNTRY>
#       {text}
#     <COMPANY>
#       {text}
#     <PRICE>
#       {text}
#     <YEAR>
#       {text}
#   <CD>

################################################################################

## Practice with xml2 functions

ls("package:xml2")
#  [1] "as_list"           "as_xml_document"   "download_html"    
#  [4] "download_xml"      "html_structure"    "read_html"        
#  [7] "read_xml"          "url_absolute"      "url_escape"       
# [10] "url_parse"         "url_relative"      "url_unescape"     
# [13] "write_html"        "write_xml"         "xml2_example"     
# [16] "xml_add_child"     "xml_add_parent"    "xml_add_sibling"  
# [19] "xml_attr"          "xml_attr<-"        "xml_attrs"        
# [22] "xml_attrs<-"       "xml_cdata"         "xml_child"        
# [25] "xml_children"      "xml_comment"       "xml_contents"     
# [28] "xml_double"        "xml_dtd"           "xml_find_all"     
# [31] "xml_find_chr"      "xml_find_first"    "xml_find_lgl"     
# [34] "xml_find_num"      "xml_find_one"      "xml_has_attr"     
# [37] "xml_integer"       "xml_length"        "xml_missing"      
# [40] "xml_name"          "xml_name<-"        "xml_new_document" 
# [43] "xml_new_root"      "xml_ns"            "xml_ns_rename"    
# [46] "xml_ns_strip"      "xml_parent"        "xml_parents"      
# [49] "xml_path"          "xml_remove"        "xml_replace"      
# [52] "xml_root"          "xml_serialize"     "xml_set_attr"     
# [55] "xml_set_attrs"     "xml_set_name"      "xml_set_namespace"
# [58] "xml_set_text"      "xml_siblings"      "xml_structure"    
# [61] "xml_text"          "xml_text<-"        "xml_type"         
# [64] "xml_unserialize"   "xml_url"           "xml_validate"     

## Show the structure
xml_structure(cd)

## Convert to list
cd_list <- as_list(cd)

################################################################################


