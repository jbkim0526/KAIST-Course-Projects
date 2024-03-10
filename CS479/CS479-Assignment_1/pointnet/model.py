import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable


class STNKd(nn.Module):
    # T-Net a.k.a. Spatial Transformer Network
    def __init__(self, k: int):
        super().__init__()
        self.k = k
        self.conv1 = nn.Sequential(nn.Conv1d(k, 64, 1), nn.BatchNorm1d(64))
        self.conv2 = nn.Sequential(nn.Conv1d(64, 128, 1), nn.BatchNorm1d(128))
        self.conv3 = nn.Sequential(nn.Conv1d(128, 1024, 1), nn.BatchNorm1d(1024))

        self.fc = nn.Sequential(
            nn.Linear(1024, 512),
            nn.BatchNorm1d(512),
            nn.ReLU(),
            nn.Linear(512, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Linear(256, k * k),
        )

    def forward(self, x):
        """
        Input: [B,k,N]
        Output: [B,k,k]
        """
        B = x.shape[0]
        device = x.device
        x = F.relu(self.conv1(x))
        x = F.relu(self.conv2(x))
        x = F.relu(self.conv3(x))
        x = torch.max(x, 2)[0]

        x = self.fc(x)
        
        # Followed the original implementation to initialize a matrix as I.
        identity = (
            Variable(torch.eye(self.k, dtype=torch.float))
            .reshape(1, self.k * self.k)
            .expand(B, -1)
            .to(device)
        )
        x = x + identity
        x = x.reshape(-1, self.k, self.k)
        return x


class PointNetFeat(nn.Module):
    """
    Corresponds to the part that extracts max-pooled features.
    """
    def __init__(
        self,
        input_transform: bool = False,
        feature_transform: bool = False,
    ):
        super().__init__()
        self.input_transform = input_transform
        self.feature_transform = feature_transform

        if self.input_transform:
            self.stn3 = STNKd(k=3)
        if self.feature_transform:
            self.stn64 = STNKd(k=64)

        # point-wise mlp
        # TODO : Implement point-wise mlp model based on PointNet Architecture.
        self.conv1 = nn.Sequential(nn.Conv1d(3, 64, 1), nn.Conv1d(64,64,1),nn.BatchNorm1d(64))
        self.conv2 = nn.Sequential(nn.Conv1d(64, 64, 1),nn.Conv1d(64, 128, 1),nn.Conv1d(128, 1024, 1),nn.BatchNorm1d(1024))

    def forward(self, pointcloud):
        """
        Input:
            - pointcloud: [B,N,3]
        Output:
            - Global feature: [B,1024]
            - ...
        """

        # TODO : Implement forward function.
        x = pointcloud.transpose(1, 2)
        if self.input_transform:
            x = torch.matmul(self.stn3.forward(x),x)
        x = F.relu(self.conv1(x))
        if self.feature_transform:
            x = torch.matmul(self.stn64.forward(x),x) 
        x = F.relu(self.conv2(x))
        x = torch.max(x, 2)[0]
        return x


class PointNetCls(nn.Module):
    def __init__(self, num_classes, input_transform, feature_transform):
        super().__init__()
        self.num_classes = num_classes
        
        # extracts max-pooled features
        self.pointnet_feat = PointNetFeat(input_transform, feature_transform)
        
        # returns the final logits from the max-pooled features.
        # TODO : Implement MLP that takes global feature as an input and return logits.
        self.conv1 = nn.Sequential(nn.Conv1d(1024,512,1), nn.Conv1d(512,256,1), nn.Conv1d(256,num_classes,1),nn.BatchNorm1d(num_classes))

    def forward(self, pointcloud):
        """
        Input:
            - pointcloud [B,N,3]
        Output:
            - logits [B,num_classes]
            - ...
        """
        # TODO : Implement forward function.
        x = self.pointnet_feat(pointcloud)
        x = x.unsqueeze(2) 
        x = F.relu(self.conv1(x))
        x = x.squeeze(2)
        return x


class PointNetPartSeg(nn.Module):
    def __init__(self, m=50):
        super().__init__()

        # returns the logits for m part labels each point (m = # of parts = 50).
        # TODO: Implement part segmentation model based on PointNet Architecture.
        self.stn3 = STNKd(k=3)
        self.stn64 = STNKd(k=64)
        self.conv1 = nn.Sequential(nn.Conv1d(3, 64, 1),nn.Conv1d(64,64,1),nn.BatchNorm1d(64))
        self.conv2 = nn.Sequential(nn.Conv1d(64, 64, 1),nn.Conv1d(64, 128, 1),nn.Conv1d(128, 1024, 1),nn.BatchNorm1d(1024))
        self.conv3 = nn.Sequential(nn.Conv1d(1088,512,1), nn.Conv1d(512,256,1), nn.Conv1d(256,128,1),nn.BatchNorm1d(128))
        self.conv4 = nn.Sequential(nn.Conv1d(128,128,1),nn.Conv1d(128,m,1),nn.BatchNorm1d(m))

    def forward(self, pointcloud):
        """
        Input:
            - pointcloud: [B,N,3]
        Output:
            - logits: [B,50,N] | 50: # of point labels
            - ...
        """
        # TODO: Implement forward function.
        B,N,_ = pointcloud.shape
        pointcloud = pointcloud.transpose(1, 2)
        x = torch.matmul(self.stn3(pointcloud),pointcloud)
        x = F.relu(self.conv1(x))
        loc_feat = torch.matmul(self.stn64(x),x) 
        x = F.relu(self.conv2(loc_feat))
        glb_feat = torch.max(x, 2)[0]
        glb_feat = glb_feat.unsqueeze(2).expand(B, 1024, N)
        x = torch.cat((loc_feat,glb_feat),dim = 1)
        x = F.relu(self.conv3(x))
        x = F.relu(self.conv4(x))
        return x

class PointNetAutoEncoder(nn.Module):
    def __init__(self, num_points):
        super().__init__()
        self.pointnet_feat = PointNetFeat()

        # Decoder is just a simple MLP that outputs N x 3 (x,y,z) coordinates.
        # TODO : Implement decoder.
        self.fc1 = nn.Sequential(nn.Linear(1024,num_points),nn.BatchNorm1d(num_points))
        self.fc2 = nn.Sequential(nn.Linear(num_points,num_points*3))
        
    def forward(self, pointcloud):
        """
        Input:
            - pointcloud [B,N,3]
        Output:
            - pointcloud [B,N,3]
            - ...
        """
        # TODO : Implement forward function.
        B,N,_ = pointcloud.shape
        lat_vec = self.pointnet_feat(pointcloud)
        x = F.relu(self.fc1(lat_vec))
        x = self.fc2(x)
        x = x.reshape(B,N,-1)
        return x

def get_orthogonal_loss(feat_trans, reg_weight=1e-3):
    """
    a regularization loss that enforces a transformation matrix to be a rotation matrix.
    Property of rotation matrix A: A*A^T = I
    """
    if feat_trans is None:
        return 0

    B, K = feat_trans.shape[:2]
    device = feat_trans.device

    identity = torch.eye(K).to(device)[None].expand(B, -1, -1)
    mat_square = torch.bmm(feat_trans, feat_trans.transpose(1, 2))

    mat_diff = (identity - mat_square).reshape(B, -1)

    return reg_weight * mat_diff.norm(dim=1).mean()
