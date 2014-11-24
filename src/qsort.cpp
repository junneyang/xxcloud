#include "quicksort.h"
using namespace std;
using namespace xCloud;

int main() {
    //int a[] = { 57, 68, 59, 52, 72, 28, 96, 33, 24 };
    int a[100],n;
    cout << "input the array size :" << endl;
    scanf("%d",&n);
    cout  << "input the array data :" << endl;
    for(int i = 0; i < n; i++) {
        scanf("%d",&a[i]); 
    }
    QuickSort* qs = new QuickSort();
    qs->quicksort(a, 0, n - 1);
    for(int i = 0; i < n; i++) {
        cout << a[i] << " ";
    }
    cout << endl;
    return 0;
}
