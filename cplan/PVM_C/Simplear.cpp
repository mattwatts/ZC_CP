//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include <iostream.h>
#include "SimpleAr.h"
//---------------------------------------------------------------------------


template<class T>
SimpleArray<T>::SimpleArray(int n){
	num_elts = n;
    ptr_to_data = new T[n];
}

template<class T>
SimpleArray<T>::SimpleArray(){
	num_elts = 0;
    ptr_to_data = 0;
}

template<class T>
SimpleArray<T>::SimpleArray(const SimpleArray<T>& a){
	num_elts = a.num_elts;
    ptr_to_data = new T[num_elts];
    copy(a);	// Copy a's elements
}

template<class T>
SimpleArray<T>::copy(const SimpleArray<T>& a){
	// Copy a's elements into the elements of *this
    T* p = prt_to_data + num_elts;
    T* q = a.ptr_to_data + num_elts;
    while (p > ptr_to_data) *--p = *--q;
}

template<class T>
SimpleArray<T>::~SimpleArray(){
	delete [] ptr_to_data;
}

template<class T>
T & SimpleArray<T>::operator[](int i){
	return prt_to_data[i];
}

template<class T>
SimpleArray<T>::numElts(){
	return num_elts;
}

template<class T>
SimpleArray<T>&SimpleArray<T>::operator=(const SimpleArray<T>& rhs){
	if (ptr_to_data != rhs.ptr_to_data){
    	setSize(rhs.num_elts);
        copy(rhs);
    }
    return *this;
}

template<class T>
SimpleArray<T>::setSize(int n){
	if (n != num_elts){
    	delete[]ptr_to_data;			// Delete old elements
        num_elts = n;					// set new count
        ptr_to_data = new T[n];			// and allocate new elements
    }
}

template<class T>
SimpleArray<T>&SimpleArray<T>::operator=(T rhs){
	T* p = ptr_to_data + num_elts;
    while (p > ptr_to_data) *--p = rhs;
    return this;
}





