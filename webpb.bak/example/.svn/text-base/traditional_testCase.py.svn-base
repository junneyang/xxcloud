#-*- coding: utf-8 -*-
#!/usr/bin/env python
import unittest
testData=[{'inputData':1,'expData':2},
{'inputData':2,'expData':4},
{'inputData':3,'expData':60}]

class under_testClass():
    def X2(self,data):
        return data*2

class traditional_testCase(unittest.TestCase):
    def setUp(self):
        #数据预置
        pass
    def tearDown(self):
        #清理工作
        pass
    def test_case000(self):
        inputData=testData[0]['inputData']
        expData=testData[0]['expData']
        actData=under_testClass().X2(inputData)
        assert(actData == expData)
    def test_case001(self):
        inputData=testData[1]['inputData']
        expData=testData[1]['expData']
        actData=under_testClass().X2(inputData)
        assert(actData == expData)
    def test_case002(self):
        inputData=testData[2]['inputData']
        expData=testData[2]['expData']
        actData=under_testClass().X2(inputData)
        assert(actData == expData)

if __name__ == '__main__':
    TestSuit=unittest.TestLoader().loadTestsFromTestCase(traditional_testCase)
    unittest.TextTestRunner(verbosity=2).run(TestSuit)

