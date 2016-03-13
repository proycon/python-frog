from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport *

cdef extern from "libfolia/folia.h" namespace "folia":
    cdef int BASE
    cdef int TextContent_t
    cdef int Text_t
    cdef int Word_t
    cdef int Str_t
    cdef int WordReference_t
    cdef int Event_t
    cdef int TimeSegment_t
    cdef int TimingLayer_t
    cdef int LineBreak_t
    cdef int WhiteSpace_t
    cdef int Sentence_t
    cdef int Paragraph_t
    cdef int Division_t
    cdef int Head_t
    cdef int Caption_t
    cdef int Label_t
    cdef int List_t
    cdef int ListItem_t
    cdef int Figure_t
    cdef int Quote_t
    cdef int Pos_t
    cdef int Lemma_t
    cdef int Phon_t
    cdef int Domain_t
    cdef int Sense_t
    cdef int Subjectivity_t
    cdef int Metric_t
    cdef int Correction_t
    cdef int AnnotationLayer_t
    cdef int SyntacticUnit_t
    cdef int Chunk_t
    cdef int Chunking_t
    cdef int Entity_t
    cdef int Entities_t
    cdef int Coreferences_t
    cdef int CoreferenceLink_t
    cdef int CoreferenceChain_t
    cdef int SyntaxLayer_t
    cdef int Semroles_t
    cdef int Semrole_t
    cdef int Morphology_t
    cdef int Morpheme_t
    cdef int ErrorDetection_t
    cdef int New_t
    cdef int Original_t
    cdef int Current_t
    cdef int Alternative_t
    cdef int Alternatives_t
    cdef int Description_t
    cdef int Gap_t
    cdef int Suggestion_t
    cdef int Content_t
    cdef int Feature_t
    cdef int SynsetFeature_t
    cdef int ActorFeature_t
    cdef int HeadFeature_t
    cdef int ValueFeature_t
    cdef int TimeFeature_t
    cdef int ModalityFeature_t
    cdef int LevelFeature_t
    cdef int BeginDateTimeFeature_t
    cdef int EndDateTimeFeature_t
    cdef int FunctionFeature_t
    cdef int PlaceHolder_t
    cdef int Dependencies_t
    cdef int Dependency_t
    cdef int Headwords_t
    cdef int DependencyDependent_t
    cdef int Alignment_t
    cdef int AlignReference_t
    cdef int Table_t
    cdef int TableHead_t
    cdef int Row_t
    cdef int Cell_t
    cdef int Lang_t
    cdef int XmlComment_t
    cdef int TokenAnnotation_t
    cdef int Structure_t
    cdef int AbstractTextMarkup_t
    cdef int TextMarkupString_t
    cdef int TextMarkupGap_t
    cdef int TextMarkupCorrection_t
    cdef int TextMarkupError_t
    cdef int TextMarkupStyle_t
    cdef int XmlText_t
    cdef int External_t
    cdef int Note_t
    cdef int Reference_t
    cdef int Part_t


    cdef cppclass FoliaElement:
        #FoliaElement * index(int) +KeyError
        int size()
        bool isinstance(int)
        string xmltag()


    cdef cppclass Document:
        Document()
        Document(string kwargs)

        bool readFromFile(string& filename) nogil
        bool readFromString(string& xml) nogil

        bool save(string&) nogil

        string toXml() nogil
