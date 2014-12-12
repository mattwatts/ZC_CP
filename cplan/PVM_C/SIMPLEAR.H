//---------------------------------------------------------------------------
#ifndef SimpleArrayH
#define SimpleArrayH
//---------------------------------------------------------------------------
#endif

template<class T>
class SimpleArray {
public:
	SimpleArray(int n);									// Create array of n elements
    SimpleArray();										// Create array of 0 elements
    SimpleArray(const SimpleArray<T>&);             	// Copy array
    T & Operator[](int i);								// Subscripting
    ~SimpleArray();										// Destroy array
    int numElts();										// Number of elements
    SimpleArray<T>& operator=(const SimpleArray<T>&);	// Array assignment
    SimpleArray<T>& operator=(T);						// Scalar assignment
    void setSize(int n);								// Change size
private:
	int num_elts;										// Number of elements
    T* ptr_to_data;                                     // Pointer to built in aray of elements
    void copy(const SimpleArray<T>& a);					// Copy in elements of a
};
