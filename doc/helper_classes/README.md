# Documentation for helper classes\n

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.


- [torchnet](10_iterator.md)
- [Df_ParallelIterator](11_paralleliterator.md)
- [Df_Tbl](20_tbl.md)
- [Df_Dict](21_dict.md)
- [Df_Array](22_array.md)

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">


- **[torchnet](10_iterator.md)**
  - [tnt.utils.table.clone(table)](10_iterator.md#utils.table.clone)
  - [tnt.utils.table.merge(dst, src)](10_iterator.md#utils.table.merge)
  - [tnt.utils.table.foreach(tbl, closure[, recursive])](10_iterator.md#utils.table.foreach)
  - [tnt.utils.table.canmergetensor(tbl)](10_iterator.md#utils.table.canmergetensor)
  - [tnt.utils.table.mergetensor(tbl)](10_iterator.md#utils.table.mergetensor)
  - [transform.identity(...)](10_iterator.md#transform.identity)
  - [tnt.ListDataset(self, list, load[, path])](10_iterator.md#ListDataset)
  - [tnt.IndexedDataset(self, fields[, path][, maxload][, mmap][, mmapidx])](10_iterator.md#IndexedDataset)
  - [tnt.IndexedDatasetWriter(self, indexfilename, datafilename, type)](10_iterator.md#IndexedDatasetWriter)
  - [tnt.IndexedDatasetWriter.add(self, tensor)](10_iterator.md#IndexedDatasetWriter.add)
  - [tnt.IndexedDatasetReader(self, indexfilename, datafilename[, mmap][, mmapidx])](10_iterator.md#IndexedDatasetReader)
  - [tnt.IndexedDatasetReader.size(self)](10_iterator.md#IndexedDatasetReader.size)
  - [tnt.IndexedDatasetReader.get(self, index)](10_iterator.md#IndexedDatasetReader.get)
  - [tnt.TransformDataset(self, dataset, transform[, key])](10_iterator.md#TransformDataset)
  - [tnt.TransformDataset(self, dataset, transforms)](10_iterator.md#TransformDataset)
  - [tnt.BatchDataset(self, dataset, batchsize[, perm][, merge][, policy])](10_iterator.md#BatchDataset)
  - [tnt.CoroutineBatchDataset(self, dataset, batchsize[, perm][, merge][, policy])](10_iterator.md#CoroutineBatchDataset)
  - [tnt.ConcatDataset(self, datasets)](10_iterator.md#ConcatDataset)
  - [tnt.ResampleDataset(self, dataset[, sampler][, size])](10_iterator.md#ResampleDataset)
  - [tnt.ShuffleDataset(self, dataset[, size][, replacement])](10_iterator.md#ShuffleDataset)
  - [tnt.ShuffleDataset.resample(self)](10_iterator.md#ShuffleDataset.resample)
  - [tnt.SplitDataset(self, dataset, partitions)](10_iterator.md#SplitDataset)
  - [tnt.SplitDataset.select(self, partition)](10_iterator.md#SplitDataset.select)
  - [tnt.DatasetIterator(self, dataset[, perm][, filter][, transform])](10_iterator.md#DatasetIterator)
  - [tnt.DatasetIterator.exec(tnt.DatasetIterator, name, ...)](10_iterator.md#DatasetIterator.exec)
  - [tnt.ParallelDatasetIterator(self[, init], closure, nthread[, perm][, filter][, transform][, ordered])](10_iterator.md#ParallelDatasetIterator)
  - [tnt.ParallelDatasetIterator.execSingle(tnt.DatasetIterator, name, ...)](10_iterator.md#ParallelDatasetIterator.execSingle)
  - [tnt.ParallelDatasetIterator.exec(tnt.DatasetIterator, name, ...)](10_iterator.md#ParallelDatasetIterator.exec)
  - [tnt.APMeter(self)](10_iterator.md#APMeter)
  - [tnt.AverageValueMeter(self)](10_iterator.md#AverageValueMeter)
  - [tnt.AUCMeter(self)](10_iterator.md#AUCMeter)
  - [tnt.ConfusionMeter(self, k[, normalized])](10_iterator.md#ConfusionMeter)
  - [tnt.mAPMeter(self)](10_iterator.md#mAPMeter)
  - [tnt.MultiLabelConfusionMeter(self, k[, normalized])](10_iterator.md#MultiLabelConfusionMeter)
  - [tnt.ClassErrorMeter(self[, topk][, accuracy])](10_iterator.md#ClassErrorMeter)
  - [tnt.TimeMeter(self[, unit])](10_iterator.md#TimeMeter)
  - [tnt.PrecisionAtKMeter(self[, topk][, dim][, online])](10_iterator.md#PrecisionAtKMeter)
  - [tnt.RecallMeter(self[, threshold][, perclass])](10_iterator.md#RecallMeter)
  - [tnt.PrecisionMeter(self[, threshold][, perclass])](10_iterator.md#PrecisionMeter)
  - [tnt.NDCGMeter(self[, K])](10_iterator.md#NDCGMeter)
  - [tnt.Log(self, keys[, onClose][, onFlush][, onGet][, onSet])](10_iterator.md#Log)
  - [tnt.Log:status(self[, message][, time])](10_iterator.md#Log.status)
  - [tnt.Log:set(self, keys)](10_iterator.md#Log.set)
  - [tnt.Log:get(self, key)](10_iterator.md#Log.get)
  - [tnt.Log:flush(self)](10_iterator.md#Log.flush)
  - [tnt.Log:close(self)](10_iterator.md#Log.close)
  - [tnt.Log:attach(self, event, closures)](10_iterator.md#Log.attach)
  - [tnt.RemoteLog(self, keys[, server][, name][, onClose][, onFlush][, onGet][, onSet])](10_iterator.md#RemoteLog)
  - [Df_Iterator(self, dataset, batch_size[, filter][, transform][, input_transform][, target_transform])](10_iterator.md#Df_Iterator)
- **[Df_ParallelIterator](11_paralleliterator.md)**
  - [Df_ParallelIterator(self, dataset, batch_size[, init], nthread[, filter][, transform][, input_transform][, target_transform][, ordered])](11_paralleliterator.md#Df_ParallelIterator)
- **[Df_Tbl](20_tbl.md)**
- **[Df_Dict](21_dict.md)**
- **[Df_Array](22_array.md)**